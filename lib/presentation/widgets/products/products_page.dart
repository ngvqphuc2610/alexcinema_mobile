import 'package:flutter/material.dart';

import '../../../core/di/dependency_injection.dart';
import '../../../data/models/entity/product_entity.dart';
import '../../../domain/services/product_service.dart';
import '../buyticket/booking_flow_shell.dart';
import 'card_products.dart';
import 'grid_products.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({
    super.key,
    this.selectedSeats = const [],
    this.ticketTotal = 0,
    this.movieTitle,
    this.showtimeLabel,
  });

  final List<String> selectedSeats;
  final double ticketTotal;
  final String? movieTitle;
  final String? showtimeLabel;

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
    final totalItems = _quantities.values.fold<int>(
      0,
      (previous, element) => previous + element,
    );
    final productTotal = _productTotal();
    final combinedTotal = widget.ticketTotal + productTotal;
    final seatsText = widget.selectedSeats.isEmpty
        ? '0 Ghế'
        : '${widget.selectedSeats.length} Ghế: ${widget.selectedSeats.join(', ')}';
    final productText = _selectedProductsSummary(totalItems);
    final subtitle = widget.movieTitle != null && widget.showtimeLabel != null
        ? '${widget.movieTitle} - ${widget.showtimeLabel}'
        : widget.movieTitle ?? widget.showtimeLabel ?? 'Chọn sản phẩm kèm vé';

    return BookingFlowShell(
      title: 'Combo',
      subtitle: subtitle,
      summaryLines: [
        seatsText,
        productText,
        'Tổng cộng: ${combinedTotal.toStringAsFixed(0)} đ',
      ],
      primaryLabel: 'Tiếp tục',
      primaryEnabled: true,
      onPrimaryAction: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tổng cộng: ${combinedTotal.toStringAsFixed(0)} đ'),
          ),
        );
      },
      child: _buildBody(),
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
            const Text(
              'Không tải được sản phẩm',
              style: TextStyle(fontWeight: FontWeight.w600),
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
      return const Center(child: Text('Chưa có sản phẩm nào.'));
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

  double _productTotal() {
    var total = 0.0;
    for (final category in _categories) {
      for (final product in category.products) {
        final qty = _quantities[product.id] ?? 0;
        total += qty * product.price;
      }
    }
    return total;
  }

  String _selectedProductsSummary(int totalItems) {
    if (totalItems == 0) {
      return 'Chưa chọn sản phẩm';
    }
    final parts = <String>[];
    for (final category in _categories) {
      for (final product in category.products) {
        final qty = _quantities[product.id] ?? 0;
        if (qty > 0) {
          parts.add('${qty}x ${product.name}');
        }
      }
    }
    return parts.isEmpty ? 'Chưa chọn sản phẩm' : parts.join(', ');
  }
}
