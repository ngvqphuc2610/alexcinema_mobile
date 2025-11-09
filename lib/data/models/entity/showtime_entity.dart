import 'package:equatable/equatable.dart';

import 'movie_entity.dart';
import 'screen_entity.dart';

class ShowtimeEntity extends Equatable {
  const ShowtimeEntity({
    required this.id,
    required this.showDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.price,
    this.movieId,
    this.screenId,
    this.format,
    this.language,
    this.subtitle,
    this.movie,
    this.screen,
  });

  final int id;
  final int? movieId;
  final int? screenId;
  final DateTime showDate;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final double price;
  final String? format;
  final String? language;
  final String? subtitle;
  final MovieEntity? movie;
  final ScreenEntity? screen;

  factory ShowtimeEntity.fromJson(Map<String, dynamic> json) {
    return ShowtimeEntity(
      id: json['id_showtime'] as int? ?? json['id'] as int? ?? 0,
      movieId: json['id_movie'] as int? ?? json['movieId'] as int?,
      screenId: json['id_screen'] as int? ?? json['screenId'] as int?,
      showDate: _parseDate(json['show_date'] ?? json['showDate']) ?? DateTime.now(),
      startTime: _parseDate(json['start_time'] ?? json['startTime']) ?? DateTime.now(),
      endTime: _parseDate(json['end_time'] ?? json['endTime']) ?? DateTime.now(),
      format: json['format'] as String?,
      language: json['language'] as String?,
      subtitle: json['subtitle'] as String?,
      status: json['status'] as String? ?? 'active',
      price: _toDouble(json['price']) ?? 0,
      movie: (json['movie'] as Map<String, dynamic>?) != null
          ? MovieEntity.fromJson(json['movie'] as Map<String, dynamic>)
          : null,
      screen: (json['screen'] as Map<String, dynamic>?) != null
          ? ScreenEntity.fromJson(json['screen'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_showtime': id,
      'id_movie': movieId,
      'id_screen': screenId,
      'show_date': showDate.toIso8601String(),
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'format': format,
      'language': language,
      'subtitle': subtitle,
      'status': status,
      'price': price,
      'movie': movie?.toJson(),
      'screen': screen?.toJson(),
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
        movieId,
        screenId,
        showDate,
        startTime,
        endTime,
        format,
        language,
        subtitle,
        status,
        price,
        movie,
        screen,
      ];
}
