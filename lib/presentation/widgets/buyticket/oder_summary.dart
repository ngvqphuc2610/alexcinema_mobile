import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_links/app_links.dart';

import '../../../core/di/dependency_injection.dart';
import '../../../data/models/dto/booking_dto.dart';
import '../../../data/models/dto/payment_dto.dart';
import '../../../data/models/entity/payment_method_entity.dart';
import '../../bloc/payment/payment_cubit.dart';
import '../../bloc/payment/payment_state.dart';
import '../../widgets/payment-methods/payment_method_picker.dart';

class SeatSelection {
  const SeatSelection({required this.code, required this.price});

  final String code;
  final double price;
}

class ConcessionSelection {
  const ConcessionSelection({
    required this.name,
    required this.price,
    this.quantity = 1,
    this.iconUrl,
  });

  final String name;
  final double price;
  final int quantity;
  final String? iconUrl;
}

class OrderSummaryPage extends StatefulWidget {
  const OrderSummaryPage({
    super.key,
    required this.bookingId,
    required this.showtimeId,
    required this.cinemaName,
    required this.showtime,
    required this.screenName,
    required this.movieTitle,
    required this.posterUrl,
    required this.durationText,
    required this.seats,
    required this.combos,
    this.seatIds = const [],
    this.userId,
    this.userEmail,
    this.userFullName,
    this.userPhone,
    this.onPaymentSucceeded,
    this.onPaymentFailed,
    this.tags = const <String>[],
    this.initialPaymentCode,
    this.holdDuration = const Duration(minutes: 10),
    this.onHoldExpired,
  });

  final int bookingId;
  final int showtimeId;
  final String cinemaName;
  final DateTime showtime;
  final String screenName;
  final String movieTitle;
  final String posterUrl;
  final String durationText;
  final List<String> tags;
  final List<SeatSelection> seats;
  final List<int> seatIds;
  final List<ConcessionSelection> combos;
  final int? userId;
  final String? userEmail;
  final String? userFullName;
  final String? userPhone;
  final String? initialPaymentCode;
  final Duration holdDuration;
  final VoidCallback? onHoldExpired;
  final void Function(PaymentStatusDto status)? onPaymentSucceeded;
  final void Function(String message)? onPaymentFailed;

  @override
  State<OrderSummaryPage> createState() => _OrderSummaryPageState();
}

class _OrderSummaryPageState extends State<OrderSummaryPage> {
  Timer? _timer;
  late Duration _remaining;
  PaymentMethodEntity? _selectedMethod;
  late AppLinks _appLinks;
  StreamSubscription? _linkSub;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _remaining = widget.holdDuration;
    _startTimer();
    _initDeepLinkListener();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _linkSub?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        final next = _remaining - const Duration(seconds: 1);
        if (next.isNegative) {
          _remaining = Duration.zero;
          timer.cancel();
          widget.onHoldExpired?.call();
        } else {
          _remaining = next;
        }
      });
    });
  }

  Future<void> _initDeepLinkListener() async {
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _handleIncomingUri(initial),
        );
      }
    } catch (_) {
      // ignore initial uri errors
    }

    _linkSub = _appLinks.uriLinkStream.listen(
      _handleIncomingUri,
      onError: (_) {},
    );
  }

  void _handleIncomingUri(Uri uri) {
    print('Deep link received: $uri'); // Debug log
    print('Scheme: ${uri.scheme}, Path: ${uri.path}'); // Debug log
    print('Query parameters: ${uri.queryParameters}'); // Debug log

    if (uri.scheme.toLowerCase() != 'alexcinema') return;
    if (!uri.path.contains('payment-result')) return;

    final transactionId =
        uri.queryParameters['appTransId'] ??
        uri.queryParameters['app_trans_id'] ??
        uri.queryParameters['transactionId'] ??
        uri.queryParameters['transId'] ??
        uri.queryParameters['apptransid'];

    print('Extracted transaction ID: $transactionId'); // Debug log

    final cubit = context.read<PaymentCubit>();
    cubit.refreshStatus(transactionId: transactionId);
  }

  @override
  Widget build(BuildContext context) {
    final seatTotal = widget.seats.fold<double>(
      0,
      (sum, item) => sum + item.price,
    );
    final comboTotal = widget.combos.fold<double>(
      0,
      (sum, item) => sum + (item.price * max(1, item.quantity)),
    );
    final grandTotal = seatTotal + comboTotal;

    return BlocProvider(
      create: (_) => serviceLocator<PaymentCubit>(),
      child: BlocConsumer<PaymentCubit, PaymentState>(
        listener: (context, state) {
          if (state.status == PaymentFlowStatus.success &&
              state.latestStatus != null) {
            widget.onPaymentSucceeded?.call(state.latestStatus!);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Thanh toán thành công')),
            );
          } else if (state.status == PaymentFlowStatus.failure &&
              state.errorMessage != null) {
            widget.onPaymentFailed?.call(state.errorMessage!);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          final isPaying = state.isBusy;
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              elevation: 0.6,
              backgroundColor: Colors.grey.shade100,
              titleSpacing: 0,
              title: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.maybePop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.black87,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.cinemaName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            _formatShowtime(widget.showtime, widget.screenName),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _formatTimer(_remaining),
                      style: const TextStyle(
                        color: Color(0xFF6C63FF),
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MovieHeader(
                    posterUrl: widget.posterUrl,
                    title: widget.movieTitle,
                    durationText: widget.durationText,
                    tags: widget.tags,
                    seats: widget.seats,
                  ),
                  const SizedBox(height: 12),
                  _Section(
                    title: 'THÔNG TIN VÉ',
                    child: Column(
                      children: [
                        _SeatPills(seats: widget.seats),
                        const SizedBox(height: 10),
                        _RowText(
                          label: 'Số lượng',
                          value: '${widget.seats.length}',
                        ),
                        _RowText(
                          label: 'Tổng',
                          value: _formatCurrency(seatTotal),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _Section(
                    title: 'THÔNG TIN BẮP NƯỚC',
                    child: Column(
                      children: [
                        ...widget.combos.map(
                          (combo) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _ComboRow(item: combo),
                          ),
                        ),
                        _RowText(
                          label: 'Tổng',
                          value: _formatCurrency(comboTotal),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _VoucherInput(),
                  const SizedBox(height: 12),
                  _Section(
                    title: 'THANH TOÁN',
                    child: Column(
                      children: [
                        _RowText(
                          label: 'Tổng cộng',
                          value: _formatCurrency(grandTotal),
                        ),
                        _RowText(label: 'Giảm giá', value: _formatCurrency(0)),
                        _RowText(
                          label: 'Còn lại',
                          value: _formatCurrency(grandTotal),
                        ),
                        const SizedBox(height: 12),
                        PaymentMethodPicker(
                          title: 'Chọn phương thức thanh toán',
                          selectedCode:
                              _selectedMethod?.code ??
                              widget.initialPaymentCode,
                          onSelected: (method) {
                            setState(() {
                              _selectedMethod = method;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isPaying || _selectedMethod == null
                          ? null
                          : () => _handlePay(context, grandTotal),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFF6A1B9A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: isPaying
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'THANH TOÁN',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                    ),
                  ),
                  if (state.status == PaymentFlowStatus.polling)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Column(
                          children: [
                            const Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.orange,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Đang chờ xác nhận thanh toán...',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Sau khi thanh toán thành công trên ZaloPay, vui lòng quay lại ứng dụng để hoàn tất.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (state.status == PaymentFlowStatus.polling &&
                      state.latestStatus != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        'Trạng thái: ${state.latestStatus!.status}',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _handlePay(BuildContext context, double amount) {
    if (_selectedMethod == null) return;
    final methodCode = _selectedMethod!.code.toUpperCase();

    // Build seats and products DTOs
    final seats = widget.seatIds
        .asMap()
        .entries
        .map(
          (entry) => BookingSeatDto(
            idSeats: entry.value,
            price: widget.seats.length > entry.key
                ? widget.seats[entry.key].price
                : null,
          ),
        )
        .toList();

    // TODO: Add products when product selection is implemented
    final products = <BookingProductDto>[];

    if (methodCode == 'ZALOPAY') {
      context.read<PaymentCubit>().payWithZalo(
        showtimeId: widget.showtimeId,
        amount: amount,
        description: widget.movieTitle,
        userId: widget.userId,
        seats: seats,
        products: products,
        guestEmail: widget.userEmail,
        guestName: widget.userFullName,
        guestPhone: widget.userPhone,
      );
    } else if (methodCode == 'VNPAY') {
      context.read<PaymentCubit>().payWithVNPay(
        showtimeId: widget.showtimeId,
        amount: amount,
        description: widget.movieTitle,
        userId: widget.userId,
        seats: seats,
        products: products,
        guestEmail: widget.userEmail,
        guestName: widget.userFullName,
        guestPhone: widget.userPhone,
      );
    } else if (methodCode == 'MOMO') {
      context.read<PaymentCubit>().payWithMoMo(
        showtimeId: widget.showtimeId,
        amount: amount,
        description: widget.movieTitle,
        userId: widget.userId,
        seats: seats,
        products: products,
        guestEmail: widget.userEmail,
        guestName: widget.userFullName,
        guestPhone: widget.userPhone,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chưa hỗ trợ phương thức $methodCode')),
      );
    }
  }
}

class _MovieHeader extends StatelessWidget {
  const _MovieHeader({
    required this.posterUrl,
    required this.title,
    required this.durationText,
    required this.tags,
    required this.seats,
  });

  final String posterUrl;
  final String title;
  final String durationText;
  final List<String> tags;
  final List<SeatSelection> seats;

  @override
  Widget build(BuildContext context) {
    final seatCodes = seats.map((e) => e.code).join(', ');
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              posterUrl,
              width: 80,
              height: 110,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 80,
                height: 110,
                color: Colors.grey.shade200,
                child: const Icon(Icons.image_not_supported),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: -6,
                  children: tags
                      .map(
                        (tag) => Chip(
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                          label: Text(tag),
                          labelStyle: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                          backgroundColor: Colors.grey.shade200,
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 6),
                Text(
                  'Thời lượng: $durationText',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                Text(
                  'Ghế: $seatCodes',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.grey.shade600,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _SeatPills extends StatelessWidget {
  const _SeatPills({required this.seats});

  final List<SeatSelection> seats;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: seats
          .map(
            (seat) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.deepPurple),
                color: Colors.white,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    seat.code,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.deepPurple,
                    ),
                  ),
                  Text(
                    _formatCurrency(seat.price),
                    style: const TextStyle(fontSize: 11, color: Colors.black87),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ComboRow extends StatelessWidget {
  const _ComboRow({required this.item});

  final ConcessionSelection item;

  @override
  Widget build(BuildContext context) {
    final qty = max(1, item.quantity);
    return Row(
      children: [
        if (item.iconUrl != null)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.iconUrl!,
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 32,
                  height: 32,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.local_cafe, size: 18),
                ),
              ),
            ),
          ),
        Expanded(
          child: Text(
            item.name,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
        Text(
          '$qty',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class _RowText extends StatelessWidget {
  const _RowText({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _VoucherInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            enabled: false,
            decoration: InputDecoration(
              hintText: 'Mã khuyến mãi',
              hintStyle: TextStyle(color: Colors.grey.shade600),
              prefixIcon: const Icon(Icons.card_giftcard_outlined),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'ÁP DỤNG',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatCurrency(double value) {
  final intPart = value.round();
  final str = intPart.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(str[i]);
  }
  return '${buffer.toString()} đ';
}

String _formatTimer(Duration duration) {
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

String _formatShowtime(DateTime showtime, String screenName) {
  final date =
      '${showtime.day.toString().padLeft(2, '0')}/${showtime.month.toString().padLeft(2, '0')}/${showtime.year}';
  final time =
      '${showtime.hour.toString().padLeft(2, '0')}:${showtime.minute.toString().padLeft(2, '0')}';
  return '$date - $time | Phòng: $screenName';
}
