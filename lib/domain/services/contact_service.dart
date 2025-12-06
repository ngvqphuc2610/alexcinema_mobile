import '../../data/models/dto/contact_dto.dart';
import '../../data/models/entity/contact_entity.dart';
import '../../data/models/entity/pagination_entity.dart';
import '../../data/repositories/contact_repository.dart';

class ContactService {
  const ContactService(this._repository);

  final ContactRepository _repository;

  Future<ContactEntity> createContact(CreateContactDto dto) {
    return _repository.createContact(dto);
  }

  Future<PaginatedResponse<ContactEntity>> getContacts(ContactQueryDto query) {
    return _repository.getContacts(query);
  }

  Future<ContactEntity> getContactById(int id) {
    return _repository.getContactById(id);
  }

  Future<ContactEntity> updateContact(int id, UpdateContactDto dto) {
    return _repository.updateContact(id, dto);
  }

  Future<void> deleteContact(int id) {
    return _repository.deleteContact(id);
  }
}
