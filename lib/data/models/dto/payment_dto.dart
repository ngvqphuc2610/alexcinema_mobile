class ZaloPayOrderResponseDto {
  ZaloPayOrderResponseDto({
    required this.appTransId,
    required this.amount,
    this.payUrl,
    this.orderUrl,
    this.returnMessage,
  });

  final String appTransId;
  final double amount;
  final String? payUrl;
  final String? orderUrl;
  final String? returnMessage;

  factory ZaloPayOrderResponseDto.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String && value.isNotEmpty) {
        return double.tryParse(value) ?? 0;
      }
      return 0;
    }

    return ZaloPayOrderResponseDto(
      appTransId: (json['appTransId'] ?? json['app_trans_id'] ?? '').toString(),
      amount: _toDouble(json['amount']),
      payUrl:
          json['payUrl'] as String? ??
          json['zp_pay_url'] as String? ??
          json['orderUrl'] as String?,
      orderUrl: json['orderUrl'] as String?,
      returnMessage: json['returnMessage'] as String?,
    );
  }
}

class VNPayOrderResponseDto {
  VNPayOrderResponseDto({
    required this.txnRef,
    required this.paymentUrl,
    required this.amount,
  });

  final String txnRef;
  final String paymentUrl;
  final double amount;

  factory VNPayOrderResponseDto.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String && value.isNotEmpty) {
        return double.tryParse(value) ?? 0;
      }
      return 0;
    }

    return VNPayOrderResponseDto(
      txnRef: (json['txnRef'] ?? '').toString(),
      paymentUrl: (json['paymentUrl'] ?? '').toString(),
      amount: _toDouble(json['amount']),
    );
  }
}

class MoMoOrderResponseDto {
  MoMoOrderResponseDto({
    required this.orderId,
    required this.payUrl,
    required this.amount,
    this.deeplink,
    this.qrCodeUrl,
  });

  final String orderId;
  final String payUrl;
  final double amount;
  final String? deeplink;
  final String? qrCodeUrl;

  factory MoMoOrderResponseDto.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String && value.isNotEmpty) {
        return double.tryParse(value) ?? 0;
      }
      return 0;
    }

    return MoMoOrderResponseDto(
      orderId: (json['orderId'] ?? '').toString(),
      payUrl: (json['payUrl'] ?? '').toString(),
      amount: _toDouble(json['amount']),
      deeplink: json['deeplink'] as String?,
      qrCodeUrl: json['qrCodeUrl'] as String?,
    );
  }
}

class PaymentStatusDto {
  PaymentStatusDto({
    required this.transactionId,
    required this.status,
    this.bookingId,
    this.bookingCode,
    this.bookingStatus,
    this.paymentStatus,
    this.amount,
    this.updatedAt,
  });

  final String transactionId;
  final String status;
  final int? bookingId;
  final String? bookingCode;
  final String? bookingStatus;
  final String? paymentStatus;
  final double? amount;
  final DateTime? updatedAt;

  factory PaymentStatusDto.fromJson(Map<String, dynamic> json) {
    DateTime? _toDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    double? _toDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String && value.isNotEmpty) {
        return double.tryParse(value);
      }
      return null;
    }

    return PaymentStatusDto(
      transactionId: (json['transactionId'] ?? json['transaction_id'] ?? '')
          .toString(),
      status: (json['status'] ?? '').toString(),
      bookingId: json['bookingId'] as int? ?? json['id_booking'] as int?,
      bookingCode: json['bookingCode'] as String?,
      bookingStatus: json['bookingStatus'] as String?,
      paymentStatus: json['paymentStatus'] as String?,
      amount: _toDouble(json['amount']),
      updatedAt: _toDate(json['updatedAt']),
    );
  }
}
