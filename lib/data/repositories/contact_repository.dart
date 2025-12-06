import '../datasources/contact_remote_data_source.dart';
import '../models/dto/contact_dto.dart';
import '../models/entity/contact_entity.dart';
import '../models/entity/pagination_entity.dart';

class ContactRepository {
  const ContactRepository(this._remoteDataSource);

  final ContactRemoteDataSource _remoteDataSource;

  Future<ContactEntity> createContact(CreateContactDto dto) {
    return _remoteDataSource.createContact(dto);
  }

  Future<PaginatedResponse<ContactEntity>> getContacts(ContactQueryDto query) {
    return _remoteDataSource.getContacts(query);
  }

  Future<ContactEntity> getContactById(int id) {
    return _remoteDataSource.getContactById(id);
  }

  Future<ContactEntity> updateContact(int id, UpdateContactDto dto) {
    return _remoteDataSource.updateContact(id, dto);
  }

  Future<void> deleteContact(int id) {
    return _remoteDataSource.deleteContact(id);
  }
}
