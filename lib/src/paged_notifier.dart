// ignore_for_file: prefer_function_declarations_over_variables

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_dev_infinite_scroll/src/paged_notifier_mixin.dart';
import 'package:riverpod_dev_infinite_scroll/src/paged_state.dart';

typedef LoadFunction<PageKeyType, ItemType> = Future<List<ItemType>?> Function(
    PageKeyType page, int limit);
typedef NextPageKeyBuilder<PageKeyType, ItemType> = PageKeyType? Function(
    List<ItemType>? lastItems, PageKeyType page, int limit);

class PagedNotifier<PageKeyType, ItemType>
    extends StateNotifier<PagedState<PageKeyType, ItemType>>
    with
        PagedNotifierMixin<PageKeyType, ItemType,
            PagedState<PageKeyType, ItemType>> {
  /// Load function
  final LoadFunction<PageKeyType, ItemType> _load;

  /// Instructs the class on how to build the next page based on the last answer
  final NextPageKeyBuilder<PageKeyType, ItemType> nextPageKeyBuilder;

  /// A builder for providing a custom error string
  final String? Function(dynamic error)? errorBuilder;

  PagedNotifier(
      {required LoadFunction<PageKeyType, ItemType> load,
      required this.nextPageKeyBuilder,
      this.errorBuilder})
      : _load = load,
        super(PagedState<PageKeyType, ItemType>());

  @override
  Future<List<ItemType>?> load(PageKeyType page, int limit) async {
    try {
      final records = await _load(page, limit);
      state = state.copyWith(
        records: [
          ...(state.records ?? <ItemType>[]),
          ...(records ?? <ItemType>[])
        ],
        nextPageKey: nextPageKeyBuilder(records, page, limit),
      );
      return records;
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
            error: errorBuilder != null
                ? errorBuilder!(e)
                : 'Si è verificato un\'errore. Per favore riprovare.');
        debugPrint(e.toString());
      }
    }
    return null;
  }
}

class NextPageKeyBuilderDefault<ItemType> {
  static NextPageKeyBuilder<int, dynamic> mysqlPagination =
      (List<dynamic>? lastItems, int page, int limit) {
    return (lastItems == null || lastItems.length < limit) ? null : (page + 1);
  };
}
