import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/di/dependency_injection.dart';
import '../../../data/models/entity/product_entity.dart';
import '../../../domain/services/product_service.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../buyticket/booking_flow_shell.dart';
import '../buyticket/oder_summary.dart';
import '../user/information_user.dart';
import 'card_products.dart';
import 'grid_products.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({
    super.key,
    required this.bookingId,
    required this.showtimeId,
    required this.cinemaName,
    required this.showtime,
    required this.screenName,
    required this.movieTitle,
    required this.posterUrl,
    required this.durationText,
    this.selectedSeats = const [],
    this.seatIds = const [],
    this.seatPrices = const {},
    this.ticketTotal = 0,
    this.tags = const [],
  });

  final int bookingId;
  final int showtimeId;
  final String cinemaName;
  final DateTime showtime;
  final String screenName;
  final String movieTitle;
  final String posterUrl;
  final String durationText;
  final List<String> selectedSeats;
  final List<int> seatIds;
  final Map<String, double> seatPrices;
  final double ticketTotal;
  final List<String> tags;

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
    final showtimeFormatted = DateFormat(
      'dd/MM/yyyy HH:mm',
    ).format(widget.showtime);
    final subtitle = '${widget.movieTitle} - $showtimeFormatted';

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
      onPrimaryAction: () => _navigateToOrderSummary(context),
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

  Future<void> _navigateToOrderSummary(BuildContext context) async {
    // Check if user is logged in
    final authState = context.read<AuthBloc>().state;
    Map<String, dynamic>? guestInfo;
    int? userId;
    String? userEmail;
    String? userFullName;
    String? userPhone;

    if (authState.isAuthenticated && authState.user != null) {
      // User is logged in
      userId = authState.user!.id;
      userEmail = authState.user!.email;
      userFullName = authState.user!.fullName;
      userPhone = authState.user!.phoneNumber;
    } else {
      // User is not logged in, show guest information form
      guestInfo = await Navigator.of(context).push<Map<String, dynamic>>(
        MaterialPageRoute(builder: (_) => const GuestInformationPage()),
      );

      // If user cancelled the form, don't proceed
      if (guestInfo == null) return;

      userEmail = guestInfo['email'] as String?;
      userFullName = guestInfo['fullName'] as String?;
      userPhone = guestInfo['phoneNumber'] as String?;
    }

    // Convert selected seats to SeatSelection objects
    final seatSelections = widget.selectedSeats
        .map(
          (seatCode) => SeatSelection(
            code: seatCode,
            price: widget.seatPrices[seatCode] ?? 0,
          ),
        )
        .toList();

    // Convert selected products to ConcessionSelection objects
    final comboSelections = <ConcessionSelection>[];
    for (final category in _categories) {
      for (final product in category.products) {
        final qty = _quantities[product.id] ?? 0;
        if (qty > 0) {
          comboSelections.add(
            ConcessionSelection(
              name: product.name,
              price: product.price,
              quantity: qty,
              iconUrl: product.image,
            ),
          );
        }
      }
    }

    if (!context.mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OrderSummaryPage(
          bookingId: widget.bookingId,
          showtimeId: widget.showtimeId,
          cinemaName: widget.cinemaName,
          showtime: widget.showtime,
          screenName: widget.screenName,
          movieTitle: widget.movieTitle,
          posterUrl: widget.posterUrl,
          durationText: widget.durationText,
          tags: widget.tags,
          seats: seatSelections,
          seatIds: widget.seatIds,
          combos: comboSelections,
          userId: userId,
          userEmail: userEmail,
          userFullName: userFullName,
          userPhone: userPhone,
          onPaymentSucceeded: (status) {
            Navigator.of(context).popUntil((route) => route.isFirst);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Thanh toán thành công! Vui lòng kiểm tra email.',
                ),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
          },
          onPaymentFailed: (message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Thanh toán thất bại: $message'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          },
          onHoldExpired: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Hết thời gian giữ ghế. Vui lòng đặt lại.'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
          },
        ),
      ),
    );
  }
}
