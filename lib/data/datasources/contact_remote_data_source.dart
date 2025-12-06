import '../models/dto/contact_dto.dart';
import '../models/entity/contact_entity.dart';
import '../models/entity/pagination_entity.dart';
import '../services/api_client.dart';

class ContactRemoteDataSource {
  final ApiClient _apiClient;

  ContactRemoteDataSource(this._apiClient);

  /// Create a new contact/support request
  Future<ContactEntity> createContact(CreateContactDto dto) async {
    print('📧 [ContactRemoteDataSource] Creating contact: ${dto.toJson()}');

    try {
      final response = await _apiClient.post(
        'contacts',
        body: dto.toJson(),
      );

      print('✅ [ContactRemoteDataSource] Contact created successfully');
      return ContactEntity.fromJson(response);
    } catch (e) {
      print('❌ [ContactRemoteDataSource] Error creating contact: $e');
      rethrow;
    }
  }

  /// Get all contacts with pagination and filters (admin only)
  Future<PaginatedResponse<ContactEntity>> getContacts(
    ContactQueryDto dto,
  ) async {
    print('📋 [ContactRemoteDataSource] Fetching contacts with query: ${dto.toQueryParameters()}');

    try {
      final response = await _apiClient.get(
        'contacts',
        queryParameters: dto.toQueryParameters(),
      );

      print('✅ [ContactRemoteDataSource] Contacts fetched successfully');

      final items = (response['items'] as List)
          .map((item) => ContactEntity.fromJson(item as Map<String, dynamic>))
          .toList();

      return PaginatedResponse(
        items: items,
        meta: PageMeta.fromJson(response['meta'] as Map<String, dynamic>),
      );
    } catch (e) {
      print('❌ [ContactRemoteDataSource] Error fetching contacts: $e');
      rethrow;
    }
  }

  /// Get a single contact by ID (admin only)
  Future<ContactEntity> getContactById(int id) async {
    print('📋 [ContactRemoteDataSource] Fetching contact with ID: $id');

    try {
      final response = await _apiClient.get('contacts/$id');

      print('✅ [ContactRemoteDataSource] Contact fetched successfully');
      return ContactEntity.fromJson(response);
    } catch (e) {
      print('❌ [ContactRemoteDataSource] Error fetching contact: $e');
      rethrow;
    }
  }

  /// Update a contact (admin only)
  Future<ContactEntity> updateContact(int id, UpdateContactDto dto) async {
    print('📝 [ContactRemoteDataSource] Updating contact $id: ${dto.toJson()}');

    try {
      final response = await _apiClient.patch(
        'contacts/$id',
        body: dto.toJson(),
      );

      print('✅ [ContactRemoteDataSource] Contact updated successfully');
      return ContactEntity.fromJson(response);
    } catch (e) {
      print('❌ [ContactRemoteDataSource] Error updating contact: $e');
      rethrow;
    }
  }

  /// Delete a contact (admin only)
  Future<void> deleteContact(int id) async {
    print('🗑️ [ContactRemoteDataSource] Deleting contact with ID: $id');

    try {
      await _apiClient.delete('contacts/$id');
      print('✅ [ContactRemoteDataSource] Contact deleted successfully');
    } catch (e) {
      print('❌ [ContactRemoteDataSource] Error deleting contact: $e');
      rethrow;
    }
  }
}
