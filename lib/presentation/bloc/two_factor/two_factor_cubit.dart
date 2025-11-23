import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/services/two_factor_service.dart';
import '../common/bloc_status.dart';
import '../common/error_helpers.dart';
import 'two_factor_state.dart';

class TwoFactorCubit extends Cubit<TwoFactorState> {
  TwoFactorCubit(this._service) : super(const TwoFactorState());

  final TwoFactorService _service;

  Future<void> enable2FA() async {
    emit(state.copyWith(status: BlocStatus.loading, clearError: true));
    try {
      final result = await _service.enable2FA();
      emit(
        state.copyWith(
          status: BlocStatus.success,
          secret: result.secret,
          qrCodeUrl: result.qrCodeUrl,
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

  Future<void> verify2FA(String code) async {
    emit(state.copyWith(status: BlocStatus.loading, clearError: true));
    try {
      final backupCodes = await _service.verify2FA(code);
      emit(
        state.copyWith(
          status: BlocStatus.success,
          backupCodes: backupCodes,
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

  Future<void> disable2FA(String code) async {
    emit(state.copyWith(status: BlocStatus.loading, clearError: true));
    try {
      await _service.disable2FA(code);
      emit(
        state.copyWith(
          status: BlocStatus.success,
          secret: null,
          qrCodeUrl: null,
          backupCodes: [],
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

  Future<void> loadBackupCodes() async {
    emit(state.copyWith(status: BlocStatus.loading, clearError: true));
    try {
      final codes = await _service.getBackupCodes();
      emit(
        state.copyWith(
          status: BlocStatus.success,
          backupCodes: codes,
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

  Future<void> regenerateBackupCodes() async {
    emit(state.copyWith(status: BlocStatus.loading, clearError: true));
    try {
      final codes = await _service.regenerateBackupCodes();
      emit(
        state.copyWith(
          status: BlocStatus.success,
          backupCodes: codes,
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
  
  void resetStatus() {
    emit(state.copyWith(status: BlocStatus.initial));
  }
}
