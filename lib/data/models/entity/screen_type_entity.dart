import 'package:equatable/equatable.dart';

class ScreenTypeEntity extends Equatable {
  const ScreenTypeEntity({
    required this.id,
    required this.typeName,
    required this.basePriceMultiplier,
    required this.status,
    this.description,
    this.technologyDescription,
    this.iconUrl,
  });

  final int id;
  final String typeName;
  final double basePriceMultiplier;
  final String status;
  final String? description;
  final String? technologyDescription;
  final String? iconUrl;

  factory ScreenTypeEntity.fromJson(Map<String, dynamic> json) {
    return ScreenTypeEntity(
      id: json['id_screentype'] as int? ?? json['id'] as int? ?? 0,
      typeName: json['type_name'] as String? ?? json['typeName'] as String? ?? '',
      description: json['description'] as String?,
      basePriceMultiplier: _toDouble(
            json['base_price_multiplier'] ?? json['basePriceMultiplier'],
          ) ??
          1,
      technologyDescription: json['technology_description'] as String? ??
          json['technologyDescription'] as String?,
      iconUrl: json['icon_url'] as String? ?? json['iconUrl'] as String?,
      status: json['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_screentype': id,
      'type_name': typeName,
      'description': description,
      'base_price_multiplier': basePriceMultiplier,
      'technology_description': technologyDescription,
      'icon_url': iconUrl,
      'status': status,
    };
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
        typeName,
        description,
        basePriceMultiplier,
        technologyDescription,
        iconUrl,
        status,
      ];
}
