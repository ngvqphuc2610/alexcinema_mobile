import 'package:equatable/equatable.dart';

import '../../../data/models/dto/screen_dto.dart';

abstract class ScreenEvent extends Equatable {
  const ScreenEvent();

  @override
  List<Object?> get props => [];
}

class ScreensRequested extends ScreenEvent {
  const ScreensRequested({this.query});

  final ScreenQueryDto? query;

  @override
  List<Object?> get props => [query];
}

class ScreenCreated extends ScreenEvent {
  const ScreenCreated(this.payload);

  final ScreenPayloadDto payload;

  @override
  List<Object?> get props => [payload];
}

class ScreenUpdated extends ScreenEvent {
  const ScreenUpdated(this.id, this.payload);

  final int id;
  final ScreenUpdateDto payload;

  @override
  List<Object?> get props => [id, payload];
}

class ScreenDeleted extends ScreenEvent {
  const ScreenDeleted(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}
