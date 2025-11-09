import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/dto/user_dto.dart';
import '../../../domain/services/user_service.dart';
import '../common/bloc_status.dart';
import '../common/error_helpers.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UsersState> {
  UserBloc(this._service) : super(const UsersState()) {
    on<UsersRequested>(_onRequested);
    on<UserUpdated>(_onUpdated);
    on<UserPasswordUpdated>(_onPasswordUpdated);
    on<UserDeleted>(_onDeleted);
  }

  final UserService _service;

  Future<void> _onRequested(
    UsersRequested event,
    Emitter<UsersState> emit,
  ) async {
    await _loadUsers(emit, event.query);
  }

  Future<void> _onUpdated(
    UserUpdated event,
    Emitter<UsersState> emit,
  ) async {
    emit(state.copyWith(operationStatus: BlocStatus.loading, clearError: true));
    try {
      await _service.updateUser(event.id, event.payload);
      emit(state.copyWith(operationStatus: BlocStatus.success));
      await _loadUsers(emit, state.lastQuery);
    } catch (error) {
      emit(
        state.copyWith(
          operationStatus: BlocStatus.failure,
          errorMessage: mapErrorMessage(error),
        ),
      );
    }
  }

  Future<void> _onPasswordUpdated(
    UserPasswordUpdated event,
    Emitter<UsersState> emit,
  ) async {
    emit(state.copyWith(operationStatus: BlocStatus.loading, clearError: true));
    try {
      await _service.updatePassword(event.id, event.payload);
      emit(state.copyWith(operationStatus: BlocStatus.success));
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
    UserDeleted event,
    Emitter<UsersState> emit,
  ) async {
    emit(state.copyWith(operationStatus: BlocStatus.loading, clearError: true));
    try {
      await _service.deleteUser(event.id);
      emit(state.copyWith(operationStatus: BlocStatus.success));
      await _loadUsers(emit, state.lastQuery);
    } catch (error) {
      emit(
        state.copyWith(
          operationStatus: BlocStatus.failure,
          errorMessage: mapErrorMessage(error),
        ),
      );
    }
  }

  Future<void> _loadUsers(
    Emitter<UsersState> emit,
    UserQueryDto? query,
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
      final response = await _service.getUsers(effectiveQuery);
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
