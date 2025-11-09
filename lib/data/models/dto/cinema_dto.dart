class CinemaPayloadDto {
  CinemaPayloadDto({
    required this.cinemaName,
    required this.address,
    required this.city,
    this.description,
    this.image,
    this.contactNumber,
    this.email,
    this.status,
  });

  final String cinemaName;
  final String address;
  final String city;
  final String? description;
  final String? image;
  final String? contactNumber;
  final String? email;
  final String? status;

  Map<String, dynamic> toJson() {
    return {
      'cinemaName': cinemaName.trim(),
      'address': address.trim(),
      'city': city.trim(),
      'description': description,
      'image': image,
      'contactNumber': contactNumber,
      'email': email,
      'status': status?.trim(),
    }..removeWhere((_, value) => value == null);
  }
}

class CinemaUpdateDto {
  CinemaUpdateDto({
    this.cinemaName,
    this.address,
    this.city,
    this.description,
    this.image,
    this.contactNumber,
    this.email,
    this.status,
  });

  final String? cinemaName;
  final String? address;
  final String? city;
  final String? description;
  final String? image;
  final String? contactNumber;
  final String? email;
  final String? status;

  Map<String, dynamic> toJson() {
    return {
      'cinemaName': cinemaName?.trim(),
      'address': address?.trim(),
      'city': city?.trim(),
      'description': description,
      'image': image,
      'contactNumber': contactNumber,
      'email': email,
      'status': status?.trim(),
    }..removeWhere((_, value) => value == null);
  }
}

class CinemaQueryDto {
  const CinemaQueryDto({
    this.page,
    this.limit,
    this.status,
    this.city,
    this.search,
  });

  final int? page;
  final int? limit;
  final String? status;
  final String? city;
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
    if (city?.isNotEmpty == true) {
      map['city'] = city!.trim();
    }
    if (search?.isNotEmpty == true) {
      map['search'] = search!.trim();
    }
    return map;
  }
}
