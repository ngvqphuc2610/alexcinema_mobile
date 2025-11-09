import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/dto/showtime_dto.dart';
import '../../../domain/services/showtime_service.dart';
import '../common/bloc_status.dart';
import '../common/error_helpers.dart';
import 'showtime_event.dart';
import 'showtime_state.dart';

class ShowtimeBloc extends Bloc<ShowtimeEvent, ShowtimeState> {
  ShowtimeBloc(this._service) : super(const ShowtimeState()) {
    on<ShowtimesRequested>(_onRequested);
    on<ShowtimeCreated>(_onCreated);
    on<ShowtimeUpdated>(_onUpdated);
    on<ShowtimeDeleted>(_onDeleted);
  }

  final ShowtimeService _service;

  Future<void> _onRequested(
    ShowtimesRequested event,
    Emitter<ShowtimeState> emit,
  ) async {
    await _loadShowtimes(emit, event.query);
  }

  Future<void> _onCreated(
    ShowtimeCreated event,
    Emitter<ShowtimeState> emit,
  ) async {
    emit(state.copyWith(operationStatus: BlocStatus.loading, clearError: true));
    try {
      await _service.createShowtime(event.payload);
      emit(state.copyWith(operationStatus: BlocStatus.success));
      await _loadShowtimes(emit, state.lastQuery);
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
    ShowtimeUpdated event,
    Emitter<ShowtimeState> emit,
  ) async {
    emit(state.copyWith(operationStatus: BlocStatus.loading, clearError: true));
    try {
      await _service.updateShowtime(event.id, event.payload);
      emit(state.copyWith(operationStatus: BlocStatus.success));
      await _loadShowtimes(emit, state.lastQuery);
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
    ShowtimeDeleted event,
    Emitter<ShowtimeState> emit,
  ) async {
    emit(state.copyWith(operationStatus: BlocStatus.loading, clearError: true));
    try {
      await _service.deleteShowtime(event.id);
      emit(state.copyWith(operationStatus: BlocStatus.success));
      await _loadShowtimes(emit, state.lastQuery);
    } catch (error) {
      emit(
        state.copyWith(
          operationStatus: BlocStatus.failure,
          errorMessage: mapErrorMessage(error),
        ),
      );
    }
  }

  Future<void> _loadShowtimes(
    Emitter<ShowtimeState> emit,
    ShowtimeQueryDto? query,
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
      final response = await _service.getShowtimes(effectiveQuery);
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
