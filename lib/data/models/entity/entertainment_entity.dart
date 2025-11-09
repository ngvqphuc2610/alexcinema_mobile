import 'package:equatable/equatable.dart';

import 'cinemas_entity.dart';

class EntertainmentEntity extends Equatable {
  const EntertainmentEntity({
    required this.id,
    required this.title,
    required this.startDate,
    required this.status,
    this.cinemaId,
    this.description,
    this.imageUrl,
    this.endDate,
    this.viewsCount,
    this.featured,
    this.staffId,
    this.cinema,
  });

  final int id;
  final int? cinemaId;
  final int? staffId;
  final String title;
  final String status;
  final DateTime startDate;
  final DateTime? endDate;
  final String? description;
  final String? imageUrl;
  final int? viewsCount;
  final bool? featured;
  final CinemaEntity? cinema;

  factory EntertainmentEntity.fromJson(Map<String, dynamic> json) {
    return EntertainmentEntity(
      id: json['id_entertainment'] as int? ?? json['id'] as int? ?? 0,
      cinemaId: json['id_cinema'] as int? ?? json['cinemaId'] as int?,
      staffId: json['id_staff'] as int? ?? json['staffId'] as int?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String? ?? json['imageUrl'] as String?,
      startDate: _parseDate(json['start_date'] ?? json['startDate']) ?? DateTime.now(),
      endDate: _parseDate(json['end_date'] ?? json['endDate']),
      status: json['status'] as String? ?? 'active',
      viewsCount: json['views_count'] as int? ?? json['viewsCount'] as int?,
      featured: json['featured'] as bool?,
      cinema: (json['cinema'] as Map<String, dynamic>?) != null
          ? CinemaEntity.fromJson(json['cinema'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_entertainment': id,
      'id_cinema': cinemaId,
      'id_staff': staffId,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'status': status,
      'views_count': viewsCount,
      'featured': featured,
      'cinema': cinema?.toJson(),
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
        cinemaId,
        staffId,
        title,
        description,
        imageUrl,
        startDate,
        endDate,
        status,
        viewsCount,
        featured,
        cinema,
      ];
}
