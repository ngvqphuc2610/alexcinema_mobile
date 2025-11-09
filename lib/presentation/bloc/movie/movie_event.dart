import 'package:equatable/equatable.dart';

import '../../../data/models/dto/movie_dto.dart';

abstract class MovieEvent extends Equatable {
  const MovieEvent();

  @override
  List<Object?> get props => [];
}

class MoviesRequested extends MovieEvent {
  const MoviesRequested({this.query});

  final MovieQueryDto? query;

  @override
  List<Object?> get props => [query];
}

class MovieCreated extends MovieEvent {
  const MovieCreated(this.payload);

  final MoviePayloadDto payload;

  @override
  List<Object?> get props => [payload];
}

class MovieUpdated extends MovieEvent {
  const MovieUpdated(this.id, this.payload);

  final int id;
  final MovieUpdateDto payload;

  @override
  List<Object?> get props => [id, payload];
}

class MovieDeleted extends MovieEvent {
  const MovieDeleted(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}
