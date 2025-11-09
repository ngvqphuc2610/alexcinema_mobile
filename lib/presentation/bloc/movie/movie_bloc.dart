import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/dto/movie_dto.dart';
import '../../../domain/services/movie_service.dart';
import '../common/bloc_status.dart';
import '../common/error_helpers.dart';
import 'movie_event.dart';
import 'movie_state.dart';

class MovieBloc extends Bloc<MovieEvent, MoviesState> {
  MovieBloc(this._service) : super(const MoviesState()) {
    on<MoviesRequested>(_onRequested);
    on<MovieCreated>(_onCreated);
    on<MovieUpdated>(_onUpdated);
    on<MovieDeleted>(_onDeleted);
  }

  final MovieService _service;

  Future<void> _onRequested(
    MoviesRequested event,
    Emitter<MoviesState> emit,
  ) async {
    await _loadMovies(emit, event.query);
  }

  Future<void> _onCreated(
    MovieCreated event,
    Emitter<MoviesState> emit,
  ) async {
    emit(state.copyWith(operationStatus: BlocStatus.loading, clearError: true));
    try {
      await _service.createMovie(event.payload);
      emit(state.copyWith(operationStatus: BlocStatus.success));
      await _loadMovies(emit, state.lastQuery);
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
    MovieUpdated event,
    Emitter<MoviesState> emit,
  ) async {
    emit(state.copyWith(operationStatus: BlocStatus.loading, clearError: true));
    try {
      await _service.updateMovie(event.id, event.payload);
      emit(state.copyWith(operationStatus: BlocStatus.success));
      await _loadMovies(emit, state.lastQuery);
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
    MovieDeleted event,
    Emitter<MoviesState> emit,
  ) async {
    emit(state.copyWith(operationStatus: BlocStatus.loading, clearError: true));
    try {
      await _service.deleteMovie(event.id);
      emit(state.copyWith(operationStatus: BlocStatus.success));
      await _loadMovies(emit, state.lastQuery);
    } catch (error) {
      emit(
        state.copyWith(
          operationStatus: BlocStatus.failure,
          errorMessage: mapErrorMessage(error),
        ),
      );
    }
  }

  Future<void> _loadMovies(
    Emitter<MoviesState> emit,
    MovieQueryDto? query,
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
      final response = await _service.getMovies(effectiveQuery);
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
