import 'package:equatable/equatable.dart';

class MovieEntity extends Equatable {
  const MovieEntity({
    required this.id,
    required this.title,
    required this.duration,
    required this.releaseDate,
    required this.status,
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
  });

  final int id;
  final String title;
  final String? originalTitle;
  final String? director;
  final String? actors;
  final int duration;
  final DateTime releaseDate;
  final DateTime? endDate;
  final String? language;
  final String? subtitle;
  final String? country;
  final String? description;
  final String? posterImage;
  final String? bannerImage;
  final String? trailerUrl;
  final String? ageRestriction;
  final String status;

  factory MovieEntity.fromJson(Map<String, dynamic> json) {
    return MovieEntity(
      id: json['id_movie'] as int? ?? json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      originalTitle: json['original_title'] as String? ?? json['originalTitle'] as String?,
      director: json['director'] as String?,
      actors: json['actors'] as String?,
      duration: json['duration'] as int? ?? 0,
      releaseDate: _parseDate(json['release_date'] ?? json['releaseDate']) ?? DateTime.now(),
      endDate: _parseDate(json['end_date'] ?? json['endDate']),
      language: json['language'] as String?,
      subtitle: json['subtitle'] as String?,
      country: json['country'] as String?,
      description: json['description'] as String?,
      posterImage: json['poster_image'] as String? ?? json['posterImage'] as String?,
      bannerImage: json['banner_image'] as String? ?? json['bannerImage'] as String?,
      trailerUrl: json['trailer_url'] as String? ?? json['trailerUrl'] as String?,
      ageRestriction: json['age_restriction'] as String? ?? json['ageRestriction'] as String?,
      status: json['status'] as String? ?? 'coming_soon',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_movie': id,
      'title': title,
      'original_title': originalTitle,
      'director': director,
      'actors': actors,
      'duration': duration,
      'release_date': releaseDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'language': language,
      'subtitle': subtitle,
      'country': country,
      'description': description,
      'poster_image': posterImage,
      'banner_image': bannerImage,
      'trailer_url': trailerUrl,
      'age_restriction': ageRestriction,
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

  @override
  List<Object?> get props => [
        id,
        title,
        originalTitle,
        director,
        actors,
        duration,
        releaseDate,
        endDate,
        language,
        subtitle,
        country,
        description,
        posterImage,
        bannerImage,
        trailerUrl,
        ageRestriction,
        status,
      ];
}
