import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../domain/services/booking_service.dart';
import '../../../domain/services/payment_service.dart';
import '../common/error_helpers.dart';
import 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  PaymentCubit(this._service, this._bookingService)
    : super(const PaymentState());

  final PaymentService _service;
  final BookingService _bookingService;
  Timer? _pollingTimer;
  int _pollAttempts = 0;
  static const int _maxPollAttempts = 30; // ~90s if interval 3s
  static const Duration _pollInterval = Duration(seconds: 3);

  Future<void> payWithZalo({
    required int showtimeId,
    required double amount,
    int? userId,
    String? description,
  }) async {
    await _stopPolling();
    emit(
      state.copyWith(
        status: PaymentFlowStatus.creatingOrder,
        errorMessage: null,
        zaloOrder: null,
        vnpayOrder: null,
        latestStatus: null,
      ),
    );

    try {
      // Step 1: Create booking first
      final bookingResponse = await _bookingService.createBooking(
        showtimeId: showtimeId,
        totalAmount: amount,
        userId: userId,
      );

      final bookingId = bookingResponse.idBooking;

      // Step 2: Create ZaloPay order with the booking ID
      final order = await _service.createZaloPayOrder(
        bookingId: bookingId,
        amount: amount,
        description: description,
      );
      emit(
        state.copyWith(status: PaymentFlowStatus.redirecting, zaloOrder: order),
      );

      final payUrl = order.payUrl ?? order.orderUrl;
      if (payUrl == null || payUrl.isEmpty) {
        throw Exception('Không có đường dẫn thanh toán');
      }

      final launched = await launchUrlString(
        payUrl,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        throw Exception('Không mở được ứng dụng thanh toán');
      }

      _startPolling(order.appTransId);
    } catch (error) {
      emit(
        state.copyWith(
          status: PaymentFlowStatus.failure,
          errorMessage: mapErrorMessage(error),
        ),
      );
    }
  }

  Future<void> payWithVNPay({
    required int showtimeId,
    required double amount,
    int? userId,
    String? description,
    String? bankCode,
  }) async {
    await _stopPolling();
    emit(
      state.copyWith(
        status: PaymentFlowStatus.creatingOrder,
        errorMessage: null,
        zaloOrder: null,
        vnpayOrder: null,
        latestStatus: null,
      ),
    );

    try {
      // Step 1: Create booking first
      final bookingResponse = await _bookingService.createBooking(
        showtimeId: showtimeId,
        totalAmount: amount,
        userId: userId,
      );

      final bookingId = bookingResponse.idBooking;

      // Step 2: Create VNPay order with the booking ID
      final order = await _service.createVNPayOrder(
        bookingId: bookingId,
        amount: amount,
        description: description,
        bankCode: bankCode,
        locale: 'vn',
      );
      emit(
        state.copyWith(
          status: PaymentFlowStatus.redirecting,
          vnpayOrder: order,
        ),
      );

      final payUrl = order.paymentUrl;
      if (payUrl.isEmpty) {
        throw Exception('Không có đường dẫn thanh toán');
      }

      final launched = await launchUrlString(
        payUrl,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        throw Exception('Không mở được ứng dụng thanh toán');
      }

      _startPolling(order.txnRef);
    } catch (error) {
      emit(
        state.copyWith(
          status: PaymentFlowStatus.failure,
          errorMessage: mapErrorMessage(error),
        ),
      );
    }
  }

  Future<void> payWithMoMo({
    required int showtimeId,
    required double amount,
    int? userId,
    String? description,
  }) async {
    await _stopPolling();
    emit(
      state.copyWith(
        status: PaymentFlowStatus.creatingOrder,
        errorMessage: null,
        zaloOrder: null,
        vnpayOrder: null,
        momoOrder: null,
        latestStatus: null,
      ),
    );

    try {
      // Step 1: Create booking first
      final bookingResponse = await _bookingService.createBooking(
        showtimeId: showtimeId,
        totalAmount: amount,
        userId: userId,
      );

      final bookingId = bookingResponse.idBooking;

      // Step 2: Create MoMo order with the booking ID
      final order = await _service.createMoMoOrder(
        bookingId: bookingId,
        amount: amount,
        description: description,
        orderInfo: description,
      );
      emit(
        state.copyWith(status: PaymentFlowStatus.redirecting, momoOrder: order),
      );

      // Prefer deeplink (opens MoMo app) over payUrl (opens browser)
      final deeplink = order.deeplink;
      final payUrl = order.payUrl;

      String? urlToLaunch;
      if (deeplink != null && deeplink.isNotEmpty) {
        // Try deeplink first (MoMo app)
        urlToLaunch = deeplink;
      } else if (payUrl.isNotEmpty) {
        // Fallback to web payment
        urlToLaunch = payUrl;
      } else {
        throw Exception('Không có đường dẫn thanh toán');
      }

      final launched = await launchUrlString(
        urlToLaunch,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        throw Exception('Không mở được ứng dụng thanh toán');
      }

      _startPolling(order.orderId);
    } catch (error) {
      emit(
        state.copyWith(
          status: PaymentFlowStatus.failure,
          errorMessage: mapErrorMessage(error),
        ),
      );
    }
  }

  Future<void> refreshStatus({String? transactionId}) async {
    final tx = transactionId ?? state.transactionId;
    print('RefreshStatus called with transactionId: $transactionId'); // Debug
    print('Final tx to fetch: $tx'); // Debug
    if (tx == null || tx.isEmpty) {
      print('No transaction ID available, skipping refresh'); // Debug
      return;
    }
    await _fetchStatus(tx, manual: true);
  }

  Future<void> _startPolling(String transactionId) async {
    await _stopPolling();
    _pollAttempts = 0;
    emit(state.copyWith(status: PaymentFlowStatus.polling));
    _pollingTimer = Timer.periodic(
      _pollInterval,
      (_) => _fetchStatus(transactionId),
    );
  }

  Future<void> _fetchStatus(String transactionId, {bool manual = false}) async {
    print('Fetching status for transaction: $transactionId'); // Debug
    try {
      final status = await _service.getPaymentStatus(transactionId);
      print('Payment status received: ${status.status}'); // Debug
      print('Full status object: $status'); // Debug

      final normalized = status.status.toLowerCase();
      if (normalized == 'success' || normalized == 'failed') {
        await _stopPolling();
        emit(
          state.copyWith(
            status: normalized == 'success'
                ? PaymentFlowStatus.success
                : PaymentFlowStatus.failure,
            latestStatus: status,
            errorMessage: normalized == 'success'
                ? null
                : 'Thanh toán thất bại',
          ),
        );
        return;
      }

      _pollAttempts += 1;
      if (_pollAttempts >= _maxPollAttempts) {
        await _stopPolling();
        emit(
          state.copyWith(
            status: PaymentFlowStatus.failure,
            latestStatus: status,
            errorMessage: 'Hết thời gian chờ xác nhận thanh toán',
          ),
        );
      } else if (manual) {
        emit(state.copyWith(latestStatus: status));
      }
    } catch (error) {
      await _stopPolling();
      emit(
        state.copyWith(
          status: PaymentFlowStatus.failure,
          errorMessage: mapErrorMessage(error),
        ),
      );
    }
  }

  Future<void> _stopPolling() async {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  @override
  Future<void> close() async {
    await _stopPolling();
    return super.close();
  }
}
