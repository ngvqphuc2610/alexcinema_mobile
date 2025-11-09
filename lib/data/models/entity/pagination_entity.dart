import 'package:equatable/equatable.dart';

class PageMeta extends Equatable {
  const PageMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final int page;
  final int limit;
  final int total;
  final int totalPages;

  factory PageMeta.fromJson(Map<String, dynamic> json) {
    return PageMeta(
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 20,
      total: json['total'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'total': total,
      'totalPages': totalPages,
    };
  }

  @override
  List<Object?> get props => [page, limit, total, totalPages];
}

class PaginatedResponse<T> extends Equatable {
  const PaginatedResponse({
    required this.items,
    required this.meta,
  });

  final List<T> items;
  final PageMeta meta;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final itemsJson = (json['items'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .toList();

    return PaginatedResponse(
      items: itemsJson.map(fromJsonT).toList(growable: false),
      meta: PageMeta.fromJson(
        json['meta'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
    );
  }

  Map<String, dynamic> toJson(
    Map<String, dynamic> Function(T value) toJsonT,
  ) {
    return {
      'items': items.map(toJsonT).toList(growable: false),
      'meta': meta.toJson(),
    };
  }

  @override
  List<Object?> get props => [items, meta];
}
