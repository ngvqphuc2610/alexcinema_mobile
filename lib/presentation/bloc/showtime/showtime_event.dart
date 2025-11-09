import 'package:equatable/equatable.dart';

import '../../../data/models/dto/showtime_dto.dart';

abstract class ShowtimeEvent extends Equatable {
  const ShowtimeEvent();

  @override
  List<Object?> get props => [];
}

class ShowtimesRequested extends ShowtimeEvent {
  const ShowtimesRequested({this.query});

  final ShowtimeQueryDto? query;

  @override
  List<Object?> get props => [query];
}

class ShowtimeCreated extends ShowtimeEvent {
  const ShowtimeCreated(this.payload);

  final ShowtimePayloadDto payload;

  @override
  List<Object?> get props => [payload];
}

class ShowtimeUpdated extends ShowtimeEvent {
  const ShowtimeUpdated(this.id, this.payload);

  final int id;
  final ShowtimeUpdateDto payload;

  @override
  List<Object?> get props => [id, payload];
}

class ShowtimeDeleted extends ShowtimeEvent {
  const ShowtimeDeleted(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}
