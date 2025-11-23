import 'package:equatable/equatable.dart';

import '../common/bloc_status.dart';

class TwoFactorState extends Equatable {
  const TwoFactorState({
    this.status = BlocStatus.initial,
    this.errorMessage,
    this.secret,
    this.qrCodeUrl,
    this.backupCodes = const [],
  });

  final BlocStatus status;
  final String? errorMessage;
  final String? secret;
  final String? qrCodeUrl;
  final List<String> backupCodes;

  TwoFactorState copyWith({
    BlocStatus? status,
    String? errorMessage,
    String? secret,
    String? qrCodeUrl,
    List<String>? backupCodes,
    bool clearError = false,
  }) {
    return TwoFactorState(
      status: status ?? this.status,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      secret: secret ?? this.secret,
      qrCodeUrl: qrCodeUrl ?? this.qrCodeUrl,
      backupCodes: backupCodes ?? this.backupCodes,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, secret, qrCodeUrl, backupCodes];
}
