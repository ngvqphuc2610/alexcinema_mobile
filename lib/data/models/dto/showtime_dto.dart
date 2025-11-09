class ShowtimePayloadDto {
  ShowtimePayloadDto({
    required this.showDate,
    required this.startTime,
    required this.endTime,
    required this.price,
    this.movieId,
    this.screenId,
    this.format,
    this.language,
    this.subtitle,
    this.status,
  });

  final int? movieId;
  final int? screenId;
  final DateTime showDate;
  final DateTime startTime;
  final DateTime endTime;
  final double price;
  final String? format;
  final String? language;
  final String? subtitle;
  final String? status;

  Map<String, dynamic> toJson() {
    return {
      'idMovie': movieId,
      'idScreen': screenId,
      'showDate': showDate.toIso8601String(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'format': format?.trim(),
      'language': language?.trim(),
      'subtitle': subtitle?.trim(),
      'status': status?.trim(),
      'price': price,
    }..removeWhere((_, value) => value == null);
  }
}

class ShowtimeUpdateDto {
  ShowtimeUpdateDto({
    this.movieId,
    this.screenId,
    this.showDate,
    this.startTime,
    this.endTime,
    this.format,
    this.language,
    this.subtitle,
    this.status,
    this.price,
  });

  final int? movieId;
  final int? screenId;
  final DateTime? showDate;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? format;
  final String? language;
  final String? subtitle;
  final String? status;
  final double? price;

  Map<String, dynamic> toJson() {
    return {
      'idMovie': movieId,
      'idScreen': screenId,
      'showDate': showDate?.toIso8601String(),
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'format': format?.trim(),
      'language': language?.trim(),
      'subtitle': subtitle?.trim(),
      'status': status?.trim(),
      'price': price,
    }..removeWhere((_, value) => value == null);
  }
}

class ShowtimeQueryDto {
  const ShowtimeQueryDto({
    this.page,
    this.limit,
    this.movieId,
    this.screenId,
    this.status,
    this.format,
    this.showDate,
  });

  final int? page;
  final int? limit;
  final int? movieId;
  final int? screenId;
  final String? status;
  final String? format;
  final DateTime? showDate;

  Map<String, String> toQueryParameters() {
    final map = <String, String>{};
    if (page != null) {
      map['page'] = '$page';
    }
    if (limit != null) {
      map['limit'] = '$limit';
    }
    if (movieId != null) {
      map['movieId'] = '$movieId';
    }
    if (screenId != null) {
      map['screenId'] = '$screenId';
    }
    if (status?.isNotEmpty == true) {
      map['status'] = status!.trim();
    }
    if (format?.isNotEmpty == true) {
      map['format'] = format!.trim();
    }
    if (showDate != null) {
      map['showDate'] = showDate!.toIso8601String();
    }
    return map;
  }
}
