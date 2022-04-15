import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_dev_infinite_scroll/src/paged_state.dart';

mixin PagedNotifierMixin<PageKeyType, ItemType,
    State extends PagedState<PageKeyType, ItemType>> on StateNotifier<State> {
  Future<List<ItemType>?> load(PageKeyType page, int limit);
}
