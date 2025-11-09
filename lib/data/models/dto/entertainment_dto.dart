class EntertainmentPayloadDto {
  EntertainmentPayloadDto({
    required this.title,
    required this.startDate,
    this.cinemaId,
    this.description,
    this.imageUrl,
    this.endDate,
    this.status,
    this.viewsCount,
    this.featured,
    this.staffId,
  });

  final int? cinemaId;
  final int? staffId;
  final String title;
  final String? description;
  final String? imageUrl;
  final DateTime startDate;
  final DateTime? endDate;
  final String? status;
  final int? viewsCount;
  final bool? featured;

  Map<String, dynamic> toJson() {
    return {
      'idCinema': cinemaId,
      'idStaff': staffId,
      'title': title.trim(),
      'description': description,
      'imageUrl': imageUrl,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'status': status?.trim(),
      'viewsCount': viewsCount,
      'featured': featured,
    }..removeWhere((_, value) => value == null);
  }
}

class EntertainmentUpdateDto {
  EntertainmentUpdateDto({
    this.cinemaId,
    this.staffId,
    this.title,
    this.description,
    this.imageUrl,
    this.startDate,
    this.endDate,
    this.status,
    this.viewsCount,
    this.featured,
  });

  final int? cinemaId;
  final int? staffId;
  final String? title;
  final String? description;
  final String? imageUrl;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? status;
  final int? viewsCount;
  final bool? featured;

  Map<String, dynamic> toJson() {
    return {
      'idCinema': cinemaId,
      'idStaff': staffId,
      'title': title?.trim(),
      'description': description,
      'imageUrl': imageUrl,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'status': status?.trim(),
      'viewsCount': viewsCount,
      'featured': featured,
    }..removeWhere((_, value) => value == null);
  }
}

class EntertainmentQueryDto {
  const EntertainmentQueryDto({
    this.page,
    this.limit,
    this.status,
    this.featured,
    this.search,
    this.cinemaId,
  });

  final int? page;
  final int? limit;
  final String? status;
  final bool? featured;
  final String? search;
  final int? cinemaId;

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
    if (featured != null) {
      map['featured'] = featured!.toString();
    }
    if (search?.isNotEmpty == true) {
      map['search'] = search!.trim();
    }
    if (cinemaId != null) {
      map['cinemaId'] = '$cinemaId';
    }
    return map;
  }
}
