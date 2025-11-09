class ScreenTypePayloadDto {
  ScreenTypePayloadDto({
    required this.typeName,
    required this.basePriceMultiplier,
    this.description,
    this.technologyDescription,
    this.iconUrl,
    this.status,
  });

  final String typeName;
  final double basePriceMultiplier;
  final String? description;
  final String? technologyDescription;
  final String? iconUrl;
  final String? status;

  Map<String, dynamic> toJson() {
    return {
      'typeName': typeName.trim(),
      'basePriceMultiplier': basePriceMultiplier,
      'description': description,
      'technologyDescription': technologyDescription,
      'iconUrl': iconUrl,
      'status': status?.trim(),
    }..removeWhere((_, value) => value == null);
  }
}

class ScreenTypeUpdateDto {
  ScreenTypeUpdateDto({
    this.typeName,
    this.basePriceMultiplier,
    this.description,
    this.technologyDescription,
    this.iconUrl,
    this.status,
  });

  final String? typeName;
  final double? basePriceMultiplier;
  final String? description;
  final String? technologyDescription;
  final String? iconUrl;
  final String? status;

  Map<String, dynamic> toJson() {
    return {
      'typeName': typeName?.trim(),
      'basePriceMultiplier': basePriceMultiplier,
      'description': description,
      'technologyDescription': technologyDescription,
      'iconUrl': iconUrl,
      'status': status?.trim(),
    }..removeWhere((_, value) => value == null);
  }
}

class ScreenTypeQueryDto {
  const ScreenTypeQueryDto({
    this.status,
    this.search,
  });

  final String? status;
  final String? search;

  Map<String, String> toQueryParameters() {
    final map = <String, String>{};
    if (status?.isNotEmpty == true) {
      map['status'] = status!.trim();
    }
    if (search?.isNotEmpty == true) {
      map['search'] = search!.trim();
    }
    return map;
  }
}
