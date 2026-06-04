import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/history.dart';
import '../../domain/repositories/history_repository.dart';
import 'app_providers.dart';

class HistoryListNotifier extends AsyncNotifier<List<History>> {
  HistoryRepository get _repository => ref.read(historyRepositoryProvider);

  @override
  Future<List<History>> build() {
    return _repository.getRecentHistories();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.getRecentHistories);
  }

  Future<void> deleteHistory(String id) async {
    await _repository.deleteHistory(id);
    await refresh();
  }

  Future<void> clearAll() async {
    await _repository.clearAllHistories();
    await refresh();
  }
}

final historyListProvider =
    AsyncNotifierProvider<HistoryListNotifier, List<History>>(
  HistoryListNotifier.new,
);
