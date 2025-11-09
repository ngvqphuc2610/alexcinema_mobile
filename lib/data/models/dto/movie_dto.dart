class MoviePayloadDto {
  MoviePayloadDto({
    required this.title,
    required this.duration,
    required this.releaseDate,
    this.originalTitle,
    this.director,
    this.actors,
    this.endDate,
    this.language,
    this.subtitle,
    this.country,
    this.description,
    this.posterImage,
    this.bannerImage,
    this.trailerUrl,
    this.ageRestriction,
    this.status,
  });

  final String title;
  final int duration;
  final DateTime releaseDate;
  final String? originalTitle;
  final String? director;
  final String? actors;
  final DateTime? endDate;
  final String? language;
  final String? subtitle;
  final String? country;
  final String? description;
  final String? posterImage;
  final String? bannerImage;
  final String? trailerUrl;
  final String? ageRestriction;
  final String? status;

  Map<String, dynamic> toJson() {
    return {
      'title': title.trim(),
      'duration': duration,
      'releaseDate': releaseDate.toIso8601String(),
      'originalTitle': originalTitle?.trim(),
      'director': director?.trim(),
      'actors': actors,
      'endDate': endDate?.toIso8601String(),
      'language': language?.trim(),
      'subtitle': subtitle?.trim(),
      'country': country?.trim(),
      'description': description,
      'posterImage': posterImage,
      'bannerImage': bannerImage,
      'trailerUrl': trailerUrl,
      'ageRestriction': ageRestriction,
      'status': status?.trim(),
    }..removeWhere((_, value) => value == null);
  }
}

class MovieUpdateDto {
  MovieUpdateDto({
    this.title,
    this.duration,
    this.releaseDate,
    this.originalTitle,
    this.director,
    this.actors,
    this.endDate,
    this.language,
    this.subtitle,
    this.country,
    this.description,
    this.posterImage,
    this.bannerImage,
    this.trailerUrl,
    this.ageRestriction,
    this.status,
  });

  final String? title;
  final int? duration;
  final DateTime? releaseDate;
  final String? originalTitle;
  final String? director;
  final String? actors;
  final DateTime? endDate;
  final String? language;
  final String? subtitle;
  final String? country;
  final String? description;
  final String? posterImage;
  final String? bannerImage;
  final String? trailerUrl;
  final String? ageRestriction;
  final String? status;

  Map<String, dynamic> toJson() {
    return {
      'title': title?.trim(),
      'duration': duration,
      'releaseDate': releaseDate?.toIso8601String(),
      'originalTitle': originalTitle?.trim(),
      'director': director?.trim(),
      'actors': actors,
      'endDate': endDate?.toIso8601String(),
      'language': language?.trim(),
      'subtitle': subtitle?.trim(),
      'country': country?.trim(),
      'description': description,
      'posterImage': posterImage,
      'bannerImage': bannerImage,
      'trailerUrl': trailerUrl,
      'ageRestriction': ageRestriction,
      'status': status?.trim(),
    }..removeWhere((_, value) => value == null);
  }
}

class MovieQueryDto {
  const MovieQueryDto({
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
