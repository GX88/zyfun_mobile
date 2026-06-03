import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/iptv.dart';
import '../../domain/repositories/iptv_repository.dart';
import 'app_providers.dart';

class IptvState {
  const IptvState({
    this.iptvs = const <Iptv>[],
    this.channels = const <Channel>[],
    this.selectedIptv,
    this.isLoading = false,
    this.isChannelLoading = false,
    this.errorMessage,
  });

  final List<Iptv> iptvs;
  final List<Channel> channels;
  final Iptv? selectedIptv;
  final bool isLoading;
  final bool isChannelLoading;
  final String? errorMessage;

  IptvState copyWith({
    List<Iptv>? iptvs,
    List<Channel>? channels,
    Iptv? selectedIptv,
    bool? isLoading,
    bool? isChannelLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return IptvState(
      iptvs: iptvs ?? this.iptvs,
      channels: channels ?? this.channels,
      selectedIptv: selectedIptv ?? this.selectedIptv,
      isLoading: isLoading ?? this.isLoading,
      isChannelLoading: isChannelLoading ?? this.isChannelLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class IptvNotifier extends StateNotifier<IptvState> {
  IptvNotifier(this._repository) : super(const IptvState());

  final IptvRepository _repository;

  Future<void> loadIptvs() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      var iptvs = await _repository.getAllIptvs();
      if (iptvs.isEmpty) {
        final now = DateTime.now().millisecondsSinceEpoch;
        const demoM3u = '''
#EXTM3U
#EXTINF:-1 group-title="演示",测试频道 1
https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4
#EXTINF:-1 group-title="演示",测试频道 2
https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4
''';
        final demo = Iptv(
          id: 'demo-iptv',
          key: 'demo-iptv',
          name: '演示直播源',
          api: demoM3u,
          type: 3,
          createdAt: now,
          updatedAt: now,
        );
        await _repository.addIptv(demo);
        await _repository.setDefaultIptv(demo.id);
        iptvs = await _repository.getAllIptvs();
      }

      final defaultId = await _repository.getDefaultIptv();
      final selected = iptvs.cast<Iptv?>().firstWhere(
            (item) => item?.id == defaultId,
            orElse: () => iptvs.isNotEmpty ? iptvs.first : null,
          );

      state = state.copyWith(
        iptvs: iptvs,
        selectedIptv: selected,
        isLoading: false,
        clearError: true,
      );

      if (selected != null) {
        await loadChannels(selected.id);
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> selectIptv(Iptv iptv) async {
    state = state.copyWith(selectedIptv: iptv, clearError: true);
    await _repository.setDefaultIptv(iptv.id);
    await loadChannels(iptv.id);
  }

  Future<void> loadChannels(String iptvId) async {
    state = state.copyWith(isChannelLoading: true, channels: const <Channel>[]);
    try {
      final channels = await _repository.getChannels(iptvId);
      state = state.copyWith(
        channels: channels,
        isChannelLoading: false,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isChannelLoading: false,
        errorMessage: error.toString(),
      );
    }
  }
}

final iptvNotifierProvider = StateNotifierProvider<IptvNotifier, IptvState>((ref) {
  return IptvNotifier(ref.watch(iptvRepositoryProvider));
});
