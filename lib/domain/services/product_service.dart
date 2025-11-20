import '../../data/models/entity/product_entity.dart';
import '../../data/repositories/product_repository.dart';

class ProductService {
  ProductService(this._repository);

  final ProductRepository _repository;

  Future<List<ProductCategoryEntity>> getCategories() {
    return _repository.getCategories();
  }
}
