import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/dto/cinema_dto.dart';
import '../../../domain/services/cinema_service.dart';
import '../common/bloc_status.dart';
import '../common/error_helpers.dart';
import 'cinema_event.dart';
import 'cinema_state.dart';

class CinemaBloc extends Bloc<CinemaEvent, CinemasState> {
  CinemaBloc(this._cinemaService) : super(const CinemasState()) {
    on<CinemasRequested>(_onRequested);
    on<CinemaCreated>(_onCreated);
    on<CinemaUpdated>(_onUpdated);
    on<CinemaDeleted>(_onDeleted);
  }

  final CinemaService _cinemaService;

  Future<void> _onRequested(
    CinemasRequested event,
    Emitter<CinemasState> emit,
  ) async {
    await _loadCinemas(emit, event.query);
  }

  Future<void> _onCreated(
    CinemaCreated event,
    Emitter<CinemasState> emit,
  ) async {
    emit(state.copyWith(operationStatus: BlocStatus.loading, clearError: true));
    try {
      await _cinemaService.createCinema(event.payload);
      emit(state.copyWith(operationStatus: BlocStatus.success));
      await _loadCinemas(emit, state.lastQuery);
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
    CinemaUpdated event,
    Emitter<CinemasState> emit,
  ) async {
    emit(state.copyWith(operationStatus: BlocStatus.loading, clearError: true));
    try {
      await _cinemaService.updateCinema(event.id, event.payload);
      emit(state.copyWith(operationStatus: BlocStatus.success));
      await _loadCinemas(emit, state.lastQuery);
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
    CinemaDeleted event,
    Emitter<CinemasState> emit,
  ) async {
    emit(state.copyWith(operationStatus: BlocStatus.loading, clearError: true));
    try {
      await _cinemaService.deleteCinema(event.id);
      emit(state.copyWith(operationStatus: BlocStatus.success));
      await _loadCinemas(emit, state.lastQuery);
    } catch (error) {
      emit(
        state.copyWith(
          operationStatus: BlocStatus.failure,
          errorMessage: mapErrorMessage(error),
        ),
      );
    }
  }

  Future<void> _loadCinemas(
    Emitter<CinemasState> emit,
    CinemaQueryDto? query,
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
      final response = await _cinemaService.getCinemas(effectiveQuery);
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
