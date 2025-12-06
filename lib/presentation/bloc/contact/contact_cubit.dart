import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/dto/contact_dto.dart';
import '../../../domain/services/contact_service.dart';
import 'contact_state.dart';

class ContactCubit extends Cubit<ContactState> {
  ContactCubit(this._contactService) : super(const ContactState());

  final ContactService _contactService;

  /// Create a new contact/support request
  Future<void> createContact({
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    emit(state.copyWith(status: ContactStatus.loading));

    try {
      final dto = CreateContactDto(
        name: name,
        email: email,
        subject: subject,
        message: message,
      );

      print('📧 [ContactCubit] Creating contact for: $email');

      await _contactService.createContact(dto);

      print('✅ [ContactCubit] Contact created successfully');

      emit(state.copyWith(
        status: ContactStatus.success,
        errorMessage: null,
      ));
    } catch (e) {
      print('❌ [ContactCubit] Error creating contact: $e');

      emit(state.copyWith(
        status: ContactStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Reset the state to initial
  void reset() {
    emit(const ContactState());
  }
}
