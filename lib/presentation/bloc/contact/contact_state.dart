import 'package:equatable/equatable.dart';

enum ContactStatus {
  initial,
  loading,
  success,
  error,
}

class ContactState extends Equatable {
  const ContactState({
    this.status = ContactStatus.initial,
    this.errorMessage,
  });

  final ContactStatus status;
  final String? errorMessage;

  bool get isLoading => status == ContactStatus.loading;
  bool get isSuccess => status == ContactStatus.success;
  bool get isError => status == ContactStatus.error;

  ContactState copyWith({
    ContactStatus? status,
    String? errorMessage,
  }) {
    return ContactState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}
