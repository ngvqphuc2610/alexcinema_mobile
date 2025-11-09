import 'package:equatable/equatable.dart';

import '../../../data/models/dto/cinema_dto.dart';

abstract class CinemaEvent extends Equatable {
  const CinemaEvent();

  @override
  List<Object?> get props => [];
}

class CinemasRequested extends CinemaEvent {
  const CinemasRequested({this.query});

  final CinemaQueryDto? query;

  @override
  List<Object?> get props => [query];
}

class CinemaCreated extends CinemaEvent {
  const CinemaCreated(this.payload);

  final CinemaPayloadDto payload;

  @override
  List<Object?> get props => [payload];
}

class CinemaUpdated extends CinemaEvent {
  const CinemaUpdated(this.id, this.payload);

  final int id;
  final CinemaUpdateDto payload;

  @override
  List<Object?> get props => [id, payload];
}

class CinemaDeleted extends CinemaEvent {
  const CinemaDeleted(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}
