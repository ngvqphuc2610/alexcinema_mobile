import 'package:equatable/equatable.dart';

import '../../../data/models/dto/screen_type_dto.dart';

abstract class ScreenTypeEvent extends Equatable {
  const ScreenTypeEvent();

  @override
  List<Object?> get props => [];
}

class ScreenTypesRequested extends ScreenTypeEvent {
  const ScreenTypesRequested({this.query});

  final ScreenTypeQueryDto? query;

  @override
  List<Object?> get props => [query];
}

class ScreenTypeCreated extends ScreenTypeEvent {
  const ScreenTypeCreated(this.payload);

  final ScreenTypePayloadDto payload;

  @override
  List<Object?> get props => [payload];
}

class ScreenTypeUpdated extends ScreenTypeEvent {
  const ScreenTypeUpdated(this.id, this.payload);

  final int id;
  final ScreenTypeUpdateDto payload;

  @override
  List<Object?> get props => [id, payload];
}

class ScreenTypeDeleted extends ScreenTypeEvent {
  const ScreenTypeDeleted(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}
