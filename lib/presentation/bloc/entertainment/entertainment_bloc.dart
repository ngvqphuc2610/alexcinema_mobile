import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/dto/entertainment_dto.dart';
import '../../../domain/services/entertainment_service.dart';
import '../common/bloc_status.dart';
import '../common/error_helpers.dart';
import 'entertainment_event.dart';
import 'entertainment_state.dart';

class EntertainmentBloc extends Bloc<EntertainmentEvent, EntertainmentState> {
  EntertainmentBloc(this._service) : super(const EntertainmentState()) {
    on<EntertainmentRequested>(_onRequested);
    on<EntertainmentCreated>(_onCreated);
    on<EntertainmentUpdated>(_onUpdated);
    on<EntertainmentDeleted>(_onDeleted);
  }

  final EntertainmentService _service;

  Future<void> _onRequested(
    EntertainmentRequested event,
    Emitter<EntertainmentState> emit,
  ) async {
    await _loadEntertainment(emit, event.query);
  }

  Future<void> _onCreated(
    EntertainmentCreated event,
    Emitter<EntertainmentState> emit,
  ) async {
    emit(state.copyWith(operationStatus: BlocStatus.loading, clearError: true));
    try {
      await _service.createEntertainment(event.payload);
      emit(state.copyWith(operationStatus: BlocStatus.success));
      await _loadEntertainment(emit, state.lastQuery);
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
    EntertainmentUpdated event,
    Emitter<EntertainmentState> emit,
  ) async {
    emit(state.copyWith(operationStatus: BlocStatus.loading, clearError: true));
    try {
      await _service.updateEntertainment(event.id, event.payload);
      emit(state.copyWith(operationStatus: BlocStatus.success));
      await _loadEntertainment(emit, state.lastQuery);
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
    EntertainmentDeleted event,
    Emitter<EntertainmentState> emit,
  ) async {
    emit(state.copyWith(operationStatus: BlocStatus.loading, clearError: true));
    try {
      await _service.deleteEntertainment(event.id);
      emit(state.copyWith(operationStatus: BlocStatus.success));
      await _loadEntertainment(emit, state.lastQuery);
    } catch (error) {
      emit(
        state.copyWith(
          operationStatus: BlocStatus.failure,
          errorMessage: mapErrorMessage(error),
        ),
      );
    }
  }

  Future<void> _loadEntertainment(
    Emitter<EntertainmentState> emit,
    EntertainmentQueryDto? query,
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
      final response = await _service.getEntertainment(effectiveQuery);
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
