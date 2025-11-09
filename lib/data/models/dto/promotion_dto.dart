class PromotionPayloadDto {
  PromotionPayloadDto({
    required this.promotionCode,
    required this.title,
    required this.startDate,
    this.description,
    this.discountPercent,
    this.discountAmount,
    this.endDate,
    this.minPurchase,
    this.maxDiscount,
    this.usageLimit,
    this.status,
  });

  final String promotionCode;
  final String title;
  final DateTime startDate;
  final String? description;
  final double? discountPercent;
  final double? discountAmount;
  final DateTime? endDate;
  final double? minPurchase;
  final double? maxDiscount;
  final int? usageLimit;
  final String? status;

  Map<String, dynamic> toJson() {
    return {
      'promotionCode': promotionCode.trim(),
      'title': title.trim(),
      'description': description,
      'discountPercent': discountPercent,
      'discountAmount': discountAmount,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'minPurchase': minPurchase,
      'maxDiscount': maxDiscount,
      'usageLimit': usageLimit,
      'status': status?.trim(),
    }..removeWhere((_, value) => value == null);
  }
}

class PromotionQueryDto {
  const PromotionQueryDto({
    this.page,
    this.limit,
    this.status,
    this.search,
  });

  final int? page;
  final int? limit;
  final String? status;
  final String? search;

  Map<String, String> toQueryParameters() {
    final map = <String, String>{};
    if (page != null) {
      map['page'] = '$page';
    }
    if (limit != null) {
      map['limit'] = '$limit';
    }
    if (status?.isNotEmpty == true) {
      map['status'] = status!.trim();
    }
    if (search?.isNotEmpty == true) {
      map['search'] = search!.trim();
    }
    return map;
  }
}
