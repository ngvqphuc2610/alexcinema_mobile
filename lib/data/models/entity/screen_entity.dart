import 'package:equatable/equatable.dart';

import 'cinemas_entity.dart';
import 'screen_type_entity.dart';

class ScreenEntity extends Equatable {
  const ScreenEntity({
    required this.id,
    required this.cinemaId,
    required this.screenName,
    required this.capacity,
    required this.status,
    this.screenTypeId,
    this.cinema,
    this.screenType,
  });

  final int id;
  final int? cinemaId;
  final int? screenTypeId;
  final String screenName;
  final int capacity;
  final String status;
  final CinemaEntity? cinema;
  final ScreenTypeEntity? screenType;

  factory ScreenEntity.fromJson(Map<String, dynamic> json) {
    return ScreenEntity(
      id: json['id_screen'] as int? ?? json['id'] as int? ?? 0,
      cinemaId: json['id_cinema'] as int? ?? json['cinemaId'] as int?,
      screenTypeId: json['id_screentype'] as int? ?? json['screenTypeId'] as int?,
      screenName: json['screen_name'] as String? ?? json['screenName'] as String? ?? '',
      capacity: json['capacity'] as int? ?? 0,
      status: json['status'] as String? ?? 'active',
      cinema: (json['cinema'] as Map<String, dynamic>?) != null
          ? CinemaEntity.fromJson(json['cinema'] as Map<String, dynamic>)
          : null,
      screenType: (json['screen_type'] as Map<String, dynamic>?) != null
          ? ScreenTypeEntity.fromJson(json['screen_type'] as Map<String, dynamic>)
          : (json['screenType'] as Map<String, dynamic>?) != null
              ? ScreenTypeEntity.fromJson(json['screenType'] as Map<String, dynamic>)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_screen': id,
      'id_cinema': cinemaId,
      'id_screentype': screenTypeId,
      'screen_name': screenName,
      'capacity': capacity,
      'status': status,
      'cinema': cinema?.toJson(),
      'screen_type': screenType?.toJson(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        cinemaId,
        screenTypeId,
        screenName,
        capacity,
        status,
        cinema,
        screenType,
      ];
}
