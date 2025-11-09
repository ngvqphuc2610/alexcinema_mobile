import 'package:equatable/equatable.dart';

import '../../../data/models/dto/entertainment_dto.dart';

abstract class EntertainmentEvent extends Equatable {
  const EntertainmentEvent();

  @override
  List<Object?> get props => [];
}

class EntertainmentRequested extends EntertainmentEvent {
  const EntertainmentRequested({this.query});

  final EntertainmentQueryDto? query;

  @override
  List<Object?> get props => [query];
}

class EntertainmentCreated extends EntertainmentEvent {
  const EntertainmentCreated(this.payload);

  final EntertainmentPayloadDto payload;

  @override
  List<Object?> get props => [payload];
}

class EntertainmentUpdated extends EntertainmentEvent {
  const EntertainmentUpdated(this.id, this.payload);

  final int id;
  final EntertainmentUpdateDto payload;

  @override
  List<Object?> get props => [id, payload];
}

class EntertainmentDeleted extends EntertainmentEvent {
  const EntertainmentDeleted(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}
