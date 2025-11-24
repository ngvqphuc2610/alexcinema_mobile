import 'package:equatable/equatable.dart';

class PromotionEntity extends Equatable {
  const PromotionEntity({
    required this.id,
    required this.promotionCode,
    required this.title,
    required this.startDate,
    required this.status,
    this.image,
    this.description,
    this.discountPercent,
    this.discountAmount,
    this.endDate,
    this.minPurchase,
    this.maxDiscount,
    this.usageLimit,
  });

  final int id;
  final String promotionCode;
  final String title;
  final String status;
  final String? image;
  final DateTime startDate;
  final String? description;
  final double? discountPercent;
  final double? discountAmount;
  final DateTime? endDate;
  final double? minPurchase;
  final double? maxDiscount;
  final int? usageLimit;

  factory PromotionEntity.fromJson(Map<String, dynamic> json) {
    return PromotionEntity(
      id: json['id_promotions'] as int? ?? json['id'] as int? ?? 0,
      promotionCode: json['promotion_code'] as String? ?? json['promotionCode'] as String? ?? '',
      title: json['title'] as String? ?? '',
      image: json['image'] as String? ?? json['image_url'] as String? ?? json['imageUrl'] as String?,
      description: json['description'] as String?,
      discountPercent: _toDouble(json['discount_percent'] ?? json['discountPercent']),
      discountAmount: _toDouble(json['discount_amount'] ?? json['discountAmount']),
      startDate: _parseDate(json['start_date'] ?? json['startDate']) ?? DateTime.now(),
      endDate: _parseDate(json['end_date'] ?? json['endDate']),
      minPurchase: _toDouble(json['min_purchase'] ?? json['minPurchase']),
      maxDiscount: _toDouble(json['max_discount'] ?? json['maxDiscount']),
      usageLimit: json['usage_limit'] as int? ?? json['usageLimit'] as int?,
      status: json['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_promotions': id,
      'promotion_code': promotionCode,
      'title': title,
      'image': image,
      'description': description,
      'discount_percent': discountPercent,
      'discount_amount': discountAmount,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'min_purchase': minPurchase,
      'max_discount': maxDiscount,
      'usage_limit': usageLimit,
      'status': status,
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static double? _toDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String && value.isNotEmpty) {
      return double.tryParse(value);
    }
    return null;
  }

  @override
  List<Object?> get props => [
        id,
        promotionCode,
        title,
        image,
        description,
        discountPercent,
        discountAmount,
        startDate,
        endDate,
        minPurchase,
        maxDiscount,
        usageLimit,
        status,
      ];
}
