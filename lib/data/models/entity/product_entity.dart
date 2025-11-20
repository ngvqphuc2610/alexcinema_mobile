import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  const ProductEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.status,
    required this.quantity,
    this.typeId,
    this.description,
    this.image,
  });

  final int id;
  final int? typeId;
  final String name;
  final String? description;
  final double price;
  final String? image;
  final String status;
  final int quantity;

  factory ProductEntity.fromJson(Map<String, dynamic> json) {
    return ProductEntity(
      id: json['id_product'] as int? ??
          json['id'] as int? ??
          json['productId'] as int? ??
          0,
      typeId: json['id_typeproduct'] as int? ?? json['typeId'] as int?,
      name: json['product_name'] as String? ?? json['name'] as String? ?? '',
      description: json['description'] as String?,
      price: _toDouble(json['price']) ?? 0,
      image: json['image'] as String?,
      status: json['status'] as String? ?? 'available',
      quantity: json['quantity'] as int? ?? 0,
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    if (value is Map && value.containsKey('value')) {
      final inner = value['value'];
      if (inner is num) return inner.toDouble();
      if (inner is String) return double.tryParse(inner);
    }
    return null;
  }

  @override
  List<Object?> get props => [
        id,
        typeId,
        name,
        description,
        price,
        image,
        status,
        quantity,
      ];
}

class ProductCategoryEntity extends Equatable {
  const ProductCategoryEntity({
    required this.id,
    required this.name,
    required this.products,
    this.description,
  });

  final int id;
  final String name;
  final String? description;
  final List<ProductEntity> products;

  factory ProductCategoryEntity.fromJson(Map<String, dynamic> json) {
    final productsJson = json['products'];
    final products = productsJson is List
        ? productsJson
            .whereType<Map<String, dynamic>>()
            .map(ProductEntity.fromJson)
            .toList()
        : <ProductEntity>[];
    return ProductCategoryEntity(
      id: json['id'] as int? ??
          json['id_typeproduct'] as int? ??
          json['typeId'] as int? ??
          0,
      name: json['name'] as String? ??
          json['type_name'] as String? ??
          'Danh mục',
      description: json['description'] as String?,
      products: products,
    );
  }

  @override
  List<Object?> get props => [id, name, description, products];
}
