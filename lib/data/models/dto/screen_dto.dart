class ScreenPayloadDto {
  ScreenPayloadDto({
    required this.screenName,
    required this.capacity,
    this.cinemaId,
    this.screenTypeId,
    this.status,
  });

  final int? cinemaId;
  final int? screenTypeId;
  final String screenName;
  final int capacity;
  final String? status;

  Map<String, dynamic> toJson() {
    return {
      'idCinema': cinemaId,
      'idScreenType': screenTypeId,
      'screenName': screenName.trim(),
      'capacity': capacity,
      'status': status?.trim(),
    }..removeWhere((_, value) => value == null);
  }
}

class ScreenUpdateDto {
  ScreenUpdateDto({
    this.cinemaId,
    this.screenTypeId,
    this.screenName,
    this.capacity,
    this.status,
  });

  final int? cinemaId;
  final int? screenTypeId;
  final String? screenName;
  final int? capacity;
  final String? status;

  Map<String, dynamic> toJson() {
    return {
      'idCinema': cinemaId,
      'idScreenType': screenTypeId,
      'screenName': screenName?.trim(),
      'capacity': capacity,
      'status': status?.trim(),
    }..removeWhere((_, value) => value == null);
  }
}

class ScreenQueryDto {
  const ScreenQueryDto({
    this.page,
    this.limit,
    this.cinemaId,
    this.screenTypeId,
    this.status,
    this.search,
    this.minCapacity,
  });

  final int? page;
  final int? limit;
  final int? cinemaId;
  final int? screenTypeId;
  final String? status;
  final String? search;
  final int? minCapacity;

  Map<String, String> toQueryParameters() {
    final map = <String, String>{};
    if (page != null) {
      map['page'] = '$page';
    }
    if (limit != null) {
      map['limit'] = '$limit';
    }
    if (cinemaId != null) {
      map['cinemaId'] = '$cinemaId';
    }
    if (screenTypeId != null) {
      map['screenTypeId'] = '$screenTypeId';
    }
    if (status?.isNotEmpty == true) {
      map['status'] = status!.trim();
    }
    if (search?.isNotEmpty == true) {
      map['search'] = search!.trim();
    }
    if (minCapacity != null) {
      map['minCapacity'] = '$minCapacity';
    }
    return map;
  }
}
