import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/dto/screen_type_dto.dart';
import '../../../domain/services/screen_type_service.dart';
import '../common/bloc_status.dart';
import '../common/error_helpers.dart';
import 'screen_type_event.dart';
import 'screen_type_state.dart';

class ScreenTypeBloc extends Bloc<ScreenTypeEvent, ScreenTypeState> {
  ScreenTypeBloc(this._service) : super(const ScreenTypeState()) {
    on<ScreenTypesRequested>(_onRequested);
    on<ScreenTypeCreated>(_onCreated);
    on<ScreenTypeUpdated>(_onUpdated);
    on<ScreenTypeDeleted>(_onDeleted);
  }

  final ScreenTypeService _service;

  Future<void> _onRequested(
    ScreenTypesRequested event,
    Emitter<ScreenTypeState> emit,
  ) async {
    await _loadTypes(emit, event.query);
  }

  Future<void> _onCreated(
    ScreenTypeCreated event,
    Emitter<ScreenTypeState> emit,
  ) async {
    emit(state.copyWith(operationStatus: BlocStatus.loading, clearError: true));
    try {
      await _service.createScreenType(event.payload);
      emit(state.copyWith(operationStatus: BlocStatus.success));
      await _loadTypes(emit, state.lastQuery);
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
    ScreenTypeUpdated event,
    Emitter<ScreenTypeState> emit,
  ) async {
    emit(state.copyWith(operationStatus: BlocStatus.loading, clearError: true));
    try {
      await _service.updateScreenType(event.id, event.payload);
      emit(state.copyWith(operationStatus: BlocStatus.success));
      await _loadTypes(emit, state.lastQuery);
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
    ScreenTypeDeleted event,
    Emitter<ScreenTypeState> emit,
  ) async {
    emit(state.copyWith(operationStatus: BlocStatus.loading, clearError: true));
    try {
      await _service.deleteScreenType(event.id);
      emit(state.copyWith(operationStatus: BlocStatus.success));
      await _loadTypes(emit, state.lastQuery);
    } catch (error) {
      emit(
        state.copyWith(
          operationStatus: BlocStatus.failure,
          errorMessage: mapErrorMessage(error),
        ),
      );
    }
  }

  Future<void> _loadTypes(
    Emitter<ScreenTypeState> emit,
    ScreenTypeQueryDto? query,
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
      final items = await _service.getScreenTypes(effectiveQuery);
      emit(
        state.copyWith(
          status: BlocStatus.success,
          items: items,
          resetMeta: true,
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
