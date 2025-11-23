import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/dto/membership_dto.dart';
import '../../../domain/services/membership_service.dart';
import '../common/bloc_status.dart';
import '../common/error_helpers.dart';
import 'membership_event.dart';
import 'membership_state.dart';

class MembershipBloc extends Bloc<MembershipEvent, MembershipState> {
  MembershipBloc(this._service) : super(const MembershipState()) {
    on<MembershipsRequested>(_onRequested);
  }

  final MembershipService _service;

  Future<void> _onRequested(
    MembershipsRequested event,
    Emitter<MembershipState> emit,
  ) async {
    final effectiveQuery = event.query ?? state.lastQuery;
    emit(
      state.copyWith(
        status: BlocStatus.loading,
        lastQuery: effectiveQuery,
        clearError: true,
      ),
    );
    try {
      final response = await _service.getMemberships(effectiveQuery);
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
