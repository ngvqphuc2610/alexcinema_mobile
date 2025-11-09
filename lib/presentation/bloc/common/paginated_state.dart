import 'package:equatable/equatable.dart';

import '../../../data/models/entity/pagination_entity.dart';
import 'bloc_status.dart';

class PaginatedState<T, Q> extends Equatable {
  const PaginatedState({
    this.status = BlocStatus.initial,
    this.operationStatus = BlocStatus.initial,
    this.items = const [],
    this.meta,
    this.lastQuery,
    this.errorMessage,
  });

  final BlocStatus status;
  final BlocStatus operationStatus;
  final List<T> items;
  final PageMeta? meta;
  final Q? lastQuery;
  final String? errorMessage;

  PaginatedState<T, Q> copyWith({
    BlocStatus? status,
    BlocStatus? operationStatus,
    List<T>? items,
    PageMeta? meta,
    Q? lastQuery,
    String? errorMessage,
    bool clearError = false,
    bool resetMeta = false,
  }) {
    return PaginatedState<T, Q>(
      status: status ?? this.status,
      operationStatus: operationStatus ?? this.operationStatus,
      items: items ?? this.items,
      meta: resetMeta ? null : meta ?? this.meta,
      lastQuery: lastQuery ?? this.lastQuery,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        operationStatus,
        items,
        meta,
        lastQuery,
        errorMessage,
      ];
}
