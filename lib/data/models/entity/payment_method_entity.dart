import 'package:equatable/equatable.dart';

class PaymentMethodEntity extends Equatable {
  const PaymentMethodEntity({
    required this.id,
    required this.code,
    required this.name,
    required this.isActive,
    required this.displayOrder,
    this.description,
    this.iconUrl,
    this.processingFee,
    this.minAmount,
    this.maxAmount,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String code;
  final String name;
  final bool isActive;
  final int displayOrder;
  final String? description;
  final String? iconUrl;
  final double? processingFee;
  final double? minAmount;
  final double? maxAmount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory PaymentMethodEntity.fromJson(Map<String, dynamic> json) {
    double? _toDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String && value.isNotEmpty) {
        return double.tryParse(value);
      }
      return null;
    }

    DateTime? _toDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    return PaymentMethodEntity(
      id: json['id'] as int? ?? json['id_payment_method'] as int? ?? 0,
      code: (json['code'] ?? json['method_code'] ?? '').toString(),
      name: (json['name'] ?? json['method_name'] ?? '').toString(),
      description: json['description'] as String?,
      iconUrl: json['iconUrl'] as String? ?? json['icon_url'] as String?,
      isActive: json['isActive'] as bool? ??
          json['is_active'] as bool? ??
          false,
      processingFee: _toDouble(json['processingFee'] ?? json['processing_fee']),
      minAmount: _toDouble(json['minAmount'] ?? json['min_amount']),
      maxAmount: _toDouble(json['maxAmount'] ?? json['max_amount']),
      displayOrder: json['displayOrder'] as int? ??
          json['display_order'] as int? ??
          0,
      createdAt: _toDate(json['createdAt'] ?? json['created_at']),
      updatedAt: _toDate(json['updatedAt'] ?? json['updated_at']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        code,
        name,
        description,
        iconUrl,
        isActive,
        processingFee,
        minAmount,
        maxAmount,
        displayOrder,
        createdAt,
        updatedAt,
      ];
}
