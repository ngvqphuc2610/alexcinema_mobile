import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/dto/promotion_dto.dart';
import '../../../domain/services/promotion_service.dart';
import '../common/bloc_status.dart';
import '../common/error_helpers.dart';
import 'promotion_event.dart';
import 'promotion_state.dart';

class PromotionBloc extends Bloc<PromotionEvent, PromotionState> {
  PromotionBloc(this._service) : super(const PromotionState()) {
    on<PromotionsRequested>(_onRequested);
    on<PromotionCreated>(_onCreated);
    on<PromotionUpdated>(_onUpdated);
    on<PromotionDeleted>(_onDeleted);
  }

  final PromotionService _service;

  Future<void> _onRequested(
    PromotionsRequested event,
    Emitter<PromotionState> emit,
  ) async {
    await _loadPromotions(emit, event.query);
  }

  Future<void> _onCreated(
    PromotionCreated event,
    Emitter<PromotionState> emit,
  ) async {
    emit(state.copyWith(operationStatus: BlocStatus.loading, clearError: true));
    try {
      await _service.createPromotion(event.payload);
      emit(state.copyWith(operationStatus: BlocStatus.success));
      await _loadPromotions(emit, state.lastQuery);
    } catch (error) {
      emit(
        state.copyWith(
          operationStatus: BlocStatus.failure,
          errorMessage: mapErrorMessage(error),
        ),
      );
    }
  }

  Future<void> _onUpdated(
    PromotionUpdated event,
    Emitter<PromotionState> emit,
  ) async {
    emit(state.copyWith(operationStatus: BlocStatus.loading, clearError: true));
    try {
      await _service.updatePromotion(event.id, event.payload);
      emit(state.copyWith(operationStatus: BlocStatus.success));
      await _loadPromotions(emit, state.lastQuery);
    } catch (error) {
      emit(
        state.copyWith(
          operationStatus: BlocStatus.failure,
          errorMessage: mapErrorMessage(error),
        ),
      );
    }
  }

  Future<void> _onDeleted(
    PromotionDeleted event,
    Emitter<PromotionState> emit,
  ) async {
    emit(state.copyWith(operationStatus: BlocStatus.loading, clearError: true));
    try {
      await _service.deletePromotion(event.id);
      emit(state.copyWith(operationStatus: BlocStatus.success));
      await _loadPromotions(emit, state.lastQuery);
    } catch (error) {
      emit(
        state.copyWith(
          operationStatus: BlocStatus.failure,
          errorMessage: mapErrorMessage(error),
        ),
      );
    }
  }

  Future<void> _loadPromotions(
    Emitter<PromotionState> emit,
    PromotionQueryDto? query,
  ) async {
    final effectiveQuery = query ?? state.lastQuery;
    emit(
      state.copyWith(
        status: BlocStatus.loading,
        lastQuery: effectiveQuery,
        clearError: true,
      ),
    );
    try {
      final response = await _service.getPromotions(effectiveQuery);
      emit(
        state.copyWith(
          status: BlocStatus.success,
          items: response.items,
          meta: response.meta,
          lastQuery: effectiveQuery,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: BlocStatus.failure,
          errorMessage: mapErrorMessage(error),
        ),
      );
    }
  }
}
