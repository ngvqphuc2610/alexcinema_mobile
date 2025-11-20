import '../datasources/product_remote_data_source.dart';
import '../models/entity/product_entity.dart';

class ProductRepository {
  const ProductRepository(this._remote);

  final ProductRemoteDataSource _remote;

  Future<List<ProductCategoryEntity>> getCategories() {
    return _remote.fetchCategories();
  }
}
