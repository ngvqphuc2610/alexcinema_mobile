import 'package:equatable/equatable.dart';

import '../../../data/models/dto/promotion_dto.dart';

abstract class PromotionEvent extends Equatable {
  const PromotionEvent();

  @override
  List<Object?> get props => [];
}

class PromotionsRequested extends PromotionEvent {
  const PromotionsRequested({this.query});

  final PromotionQueryDto? query;

  @override
  List<Object?> get props => [query];
}

class PromotionCreated extends PromotionEvent {
  const PromotionCreated(this.payload);

  final PromotionPayloadDto payload;

  @override
  List<Object?> get props => [payload];
}

class PromotionUpdated extends PromotionEvent {
  const PromotionUpdated(this.id, this.payload);

  final int id;
  final PromotionPayloadDto payload;

  @override
  List<Object?> get props => [id, payload];
}

class PromotionDeleted extends PromotionEvent {
  const PromotionDeleted(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}
