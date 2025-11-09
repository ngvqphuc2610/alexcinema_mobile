import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/dto/screen_dto.dart';
import '../../../domain/services/screen_service.dart';
import '../common/bloc_status.dart';
import '../common/error_helpers.dart';
import 'screen_event.dart';
import 'screen_state.dart';

class ScreenBloc extends Bloc<ScreenEvent, ScreensState> {
  ScreenBloc(this._service) : super(const ScreensState()) {
    on<ScreensRequested>(_onRequested);
    on<ScreenCreated>(_onCreated);
    on<ScreenUpdated>(_onUpdated);
    on<ScreenDeleted>(_onDeleted);
  }

  final ScreenService _service;

  Future<void> _onRequested(
    ScreensRequested event,
    Emitter<ScreensState> emit,
  ) async {
    await _loadScreens(emit, event.query);
  }

  Future<void> _onCreated(
    ScreenCreated event,
    Emitter<ScreensState> emit,
  ) async {
    emit(state.copyWith(operationStatus: BlocStatus.loading, clearError: true));
    try {
      await _service.createScreen(event.payload);
      emit(state.copyWith(operationStatus: BlocStatus.success));
      await _loadScreens(emit, state.lastQuery);
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
    ScreenUpdated event,
    Emitter<ScreensState> emit,
  ) async {
    emit(state.copyWith(operationStatus: BlocStatus.loading, clearError: true));
    try {
      await _service.updateScreen(event.id, event.payload);
      emit(state.copyWith(operationStatus: BlocStatus.success));
      await _loadScreens(emit, state.lastQuery);
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
    ScreenDeleted event,
    Emitter<ScreensState> emit,
  ) async {
    emit(state.copyWith(operationStatus: BlocStatus.loading, clearError: true));
    try {
      await _service.deleteScreen(event.id);
      emit(state.copyWith(operationStatus: BlocStatus.success));
      await _loadScreens(emit, state.lastQuery);
    } catch (error) {
      emit(
        state.copyWith(
          operationStatus: BlocStatus.failure,
          errorMessage: mapErrorMessage(error),
        ),
      );
    }
  }

  Future<void> _loadScreens(
    Emitter<ScreensState> emit,
    ScreenQueryDto? query,
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
      final response = await _service.getScreens(effectiveQuery);
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
