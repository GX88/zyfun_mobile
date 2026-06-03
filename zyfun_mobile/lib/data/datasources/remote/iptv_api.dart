import 'package:dio/dio.dart';

import '../../models/iptv.dart';
import 'api_client.dart';

class IptvApi {
  IptvApi({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<String> fetchM3uContent(Iptv iptv) async {
    if (!iptv.isRemote) {
      return iptv.api;
    }

    final response = await _apiClient.get<String>(
      iptv.api,
      options: Options(
        responseType: ResponseType.plain,
        headers: iptv.headers,
      ),
    );

    return response.data ?? '';
  }

  Future<List<Channel>> getChannels(Iptv iptv) async {
    final content = await fetchM3uContent(iptv);
    return parseM3u(content);
  }

  List<Channel> parseM3u(String content) {
    final normalized = content.trim();
    if (normalized.isEmpty) {
      return const <Channel>[];
    }

    final lines = normalized
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final channels = <Channel>[];
    String? pendingName;
    String? pendingLogo;
    String? pendingGroup;
    Map<String, String>? pendingHeaders;

    for (final line in lines) {
      if (line.startsWith('#EXTINF')) {
        final metadata = _parseExtInf(line);
        pendingName = metadata.name;
        pendingLogo = metadata.logo;
        pendingGroup = metadata.group;
        continue;
      }

      if (line.startsWith('#EXTVLCOPT:')) {
        pendingHeaders = {
          ...?pendingHeaders,
          ..._parseExtVlcOpt(line),
        };
        continue;
      }

      if (line.startsWith('#')) {
        continue;
      }

      channels.add(
        Channel(
          id: 'channel-${channels.length + 1}',
          name: pendingName ?? '频道 ${channels.length + 1}',
          url: line,
          logo: pendingLogo,
          group: pendingGroup,
          headers: pendingHeaders,
        ),
      );

      pendingName = null;
      pendingLogo = null;
      pendingGroup = null;
      pendingHeaders = null;
    }

    return channels;
  }

  _ExtInfMeta _parseExtInf(String line) {
    final name = line.split(',').last.trim();
    final tvgLogo = _matchAttribute(line, 'tvg-logo');
    final groupTitle = _matchAttribute(line, 'group-title');

    return _ExtInfMeta(
      name: name.isEmpty ? '未命名频道' : name,
      logo: tvgLogo,
      group: groupTitle,
    );
  }

  Map<String, String> _parseExtVlcOpt(String line) {
    final payload = line.replaceFirst('#EXTVLCOPT:', '').trim();
    final separatorIndex = payload.indexOf('=');
    if (separatorIndex == -1) {
      return const <String, String>{};
    }

    final key = payload.substring(0, separatorIndex).trim();
    final value = payload.substring(separatorIndex + 1).trim();
    if (key.isEmpty || value.isEmpty) {
      return const <String, String>{};
    }

    return <String, String>{key: value};
  }

  String? _matchAttribute(String line, String key) {
    final match = RegExp('$key="([^"]*)"').firstMatch(line);
    if (match == null) {
      return null;
    }

    final value = match.group(1)?.trim();
    return value == null || value.isEmpty ? null : value;
  }
}

class _ExtInfMeta {
  const _ExtInfMeta({
    required this.name,
    this.logo,
    this.group,
  });

  final String name;
  final String? logo;
  final String? group;
}
