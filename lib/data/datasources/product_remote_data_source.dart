import '../models/entity/product_entity.dart';
import '../services/api_client.dart';
import '../services/api_utils.dart';

class ProductRemoteDataSource {
  const ProductRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<ProductCategoryEntity>> fetchCategories() async {
    final response = await _client.get('product');
    final list = ensureList(response, errorMessage: 'Invalid product response');
    return list.map(ProductCategoryEntity.fromJson).toList(growable: false);
  }
}
