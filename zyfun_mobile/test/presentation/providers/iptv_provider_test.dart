import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zyfun_mobile/data/models/iptv.dart';
import 'package:zyfun_mobile/domain/repositories/iptv_repository.dart';
import 'package:zyfun_mobile/presentation/providers/app_providers.dart';
import 'package:zyfun_mobile/presentation/providers/iptv_provider.dart';

void main() {
  group('IptvNotifier', () {
    test('空仓库会注入默认直播源并加载频道', () async {
      final repository = FakeIptvRepository();
      final container = ProviderContainer(
        overrides: <Override>[
          iptvRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(iptvNotifierProvider.notifier);
      await notifier.loadIptvs();

      final state = container.read(iptvNotifierProvider);
      expect(state.iptvs, hasLength(1));
      expect(state.selectedIptv?.id, 'demo-iptv');
      expect(state.channels, isNotEmpty);
      expect(state.channels.first.name, '测试频道 1');
      expect(repository.defaultIptvId, 'demo-iptv');
    });

    test('切换直播源会更新默认值并重新加载频道', () async {
      final repository = FakeIptvRepository(
        iptvs: <Iptv>[
          _buildIptv(id: 'iptv-a', name: '源 A', api: 'source-a'),
          _buildIptv(id: 'iptv-b', name: '源 B', api: 'source-b'),
        ],
        channelsById: <String, List<Channel>>{
          'iptv-a': <Channel>[
            const Channel(id: 'a-1', name: 'A1', url: 'https://example.com/a1.m3u8'),
          ],
          'iptv-b': <Channel>[
            const Channel(id: 'b-1', name: 'B1', url: 'https://example.com/b1.m3u8'),
            const Channel(id: 'b-2', name: 'B2', url: 'https://example.com/b2.m3u8'),
          ],
        },
        defaultIptvId: 'iptv-a',
      );
      final container = ProviderContainer(
        overrides: <Override>[
          iptvRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(iptvNotifierProvider.notifier);
      await notifier.loadIptvs();
      await notifier.selectIptv(repository.iptvs[1]);

      final state = container.read(iptvNotifierProvider);
      expect(state.selectedIptv?.id, 'iptv-b');
      expect(state.channels, hasLength(2));
      expect(state.channels.first.name, 'B1');
      expect(repository.defaultIptvId, 'iptv-b');
    });

    test('频道加载失败会写入错误状态', () async {
      final repository = FakeIptvRepository(
        iptvs: <Iptv>[
          _buildIptv(id: 'iptv-a', name: '源 A', api: 'source-a'),
        ],
        defaultIptvId: 'iptv-a',
        failOnChannelLoad: true,
      );
      final container = ProviderContainer(
        overrides: <Override>[
          iptvRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(iptvNotifierProvider.notifier);
      await notifier.loadIptvs();

      final state = container.read(iptvNotifierProvider);
      expect(state.channels, isEmpty);
      expect(state.errorMessage, contains('频道加载失败'));
      expect(state.isChannelLoading, isFalse);
    });
  });
}

Iptv _buildIptv({
  required String id,
  required String name,
  required String api,
}) {
  return Iptv(
    id: id,
    key: id,
    name: name,
    api: api,
    type: 3,
    createdAt: 1,
    updatedAt: 1,
  );
}

class FakeIptvRepository implements IptvRepository {
  FakeIptvRepository({
    List<Iptv>? iptvs,
    Map<String, List<Channel>>? channelsById,
    this.defaultIptvId,
    this.failOnChannelLoad = false,
  })  : iptvs = List<Iptv>.from(iptvs ?? const <Iptv>[]),
        channelsById = Map<String, List<Channel>>.from(channelsById ?? const <String, List<Channel>>{});

  final List<Iptv> iptvs;
  final Map<String, List<Channel>> channelsById;
  String? defaultIptvId;
  final bool failOnChannelLoad;

  @override
  Future<void> addIptv(Iptv iptv) async {
    iptvs.add(iptv);
  }

  @override
  Future<void> deleteIptv(String id) async {
    iptvs.removeWhere((iptv) => iptv.id == id);
  }

  @override
  Future<List<Iptv>> getAllIptvs() async {
    return List<Iptv>.from(iptvs);
  }

  @override
  Future<List<Channel>> getChannels(String iptvId) async {
    if (failOnChannelLoad) {
      throw Exception('频道加载失败');
    }
    if (iptvId == 'demo-iptv') {
      return <Channel>[
        const Channel(
          id: 'demo-1',
          name: '测试频道 1',
          url: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
          group: '演示',
        ),
      ];
    }
    return List<Channel>.from(channelsById[iptvId] ?? const <Channel>[]);
  }

  @override
  Future<Iptv?> getIptvById(String id) async {
    return iptvs.cast<Iptv?>().firstWhere(
          (iptv) => iptv?.id == id,
          orElse: () => null,
        );
  }

  @override
  Future<String?> getDefaultIptv() async {
    return defaultIptvId;
  }

  @override
  Future<List<Channel>> parseM3u(String content) async {
    return <Channel>[];
  }

  @override
  Future<void> setDefaultIptv(String id) async {
    defaultIptvId = id;
  }

  @override
  Future<void> updateIptv(Iptv iptv) async {
    final index = iptvs.indexWhere((item) => item.id == iptv.id);
    if (index >= 0) {
      iptvs[index] = iptv;
    }
  }
}
