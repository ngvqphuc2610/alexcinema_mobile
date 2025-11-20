import 'package:flutter/material.dart';

import '../../../core/di/dependency_injection.dart';
import '../../../data/models/entity/product_entity.dart';
import '../../../domain/services/product_service.dart';
import 'card_products.dart';
import 'grid_products.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  late final ProductService _productService;
  List<ProductCategoryEntity> _categories = const [];
  final Map<int, bool> _expanded = {};
  final Map<int, int> _quantities = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _productService = serviceLocator<ProductService>();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final categories = await _productService.getCategories();
      setState(() {
        _categories = categories;
        _syncLocalState(categories);
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  void _syncLocalState(List<ProductCategoryEntity> categories) {
    if (categories.isEmpty) {
      _expanded.clear();
      _quantities.clear();
      return;
    }
    for (var i = 0; i < categories.length; i++) {
      final category = categories[i];
      _expanded.putIfAbsent(category.id, () => i == 0);
      for (final product in category.products) {
        _quantities.putIfAbsent(product.id, () => 0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('Combo'),
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildCheckoutBar(context),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Không thể tải sản phẩm',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _fetchProducts,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_categories.isEmpty) {
      return const Center(
        child: Text('Chưa có sản phẩm nào.'),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchProducts,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final products = category.products
              .map(
                (product) => ProductCard(
                  title: product.name,
                  price: product.price,
                  imageUrl: product.image,
                  quantity: _quantities[product.id] ?? 0,
                  onIncrement: () => _updateQuantity(product.id, 1),
                  onDecrement: () => _updateQuantity(product.id, -1),
                ),
              )
              .toList();

          return ProductCategoryPanel(
            title: category.name,
            children: products,
            isExpanded: _expanded[category.id] ?? false,
            onToggle: () => _toggleCategory(category.id),
          );
        },
      ),
    );
  }

  void _toggleCategory(int categoryId) {
    setState(() {
      _expanded[categoryId] = !(_expanded[categoryId] ?? false);
    });
  }

  void _updateQuantity(int productId, int delta) {
    setState(() {
      final current = _quantities[productId] ?? 0;
      final next = (current + delta).clamp(0, 99);
      _quantities[productId] = next;
    });
  }

  Widget _buildCheckoutBar(BuildContext context) {
    final totalItems =
        _quantities.values.fold<int>(0, (previous, element) => previous + element);
    if (totalItems == 0) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Text(
          'Tiếp tục • $totalItems mục',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
