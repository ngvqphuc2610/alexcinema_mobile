class CreateBookingDto {
  const CreateBookingDto({
    required this.idShowtime,
    required this.totalAmount,
    this.idUsers,
    this.bookingStatus = 'pending',
    this.paymentStatus = 'unpaid',
  });

  final int? idUsers;
  final int idShowtime;
  final double totalAmount;
  final String bookingStatus;
  final String paymentStatus;

  Map<String, dynamic> toJson() {
    return {
      if (idUsers != null) 'idUsers': idUsers,
      'idShowtime': idShowtime,
      'totalAmount': totalAmount.toInt(),
      'bookingStatus': bookingStatus,
      'paymentStatus': paymentStatus,
      'bookingDate': DateTime.now().toIso8601String(),
    };
  }
}

class BookingResponseDto {
  const BookingResponseDto({
    required this.idBooking,
    required this.bookingCode,
    required this.totalAmount,
    required this.bookingStatus,
    required this.paymentStatus,
  });

  final int idBooking;
  final String? bookingCode;
  final double totalAmount;
  final String bookingStatus;
  final String paymentStatus;

  factory BookingResponseDto.fromJson(Map<String, dynamic> json) {
    final totalAmountRaw = json['total_amount'] ?? json['totalAmount'];
    final totalAmount = totalAmountRaw is String
        ? double.parse(totalAmountRaw)
        : (totalAmountRaw as num).toDouble();

    return BookingResponseDto(
      idBooking: json['id_booking'] as int? ?? json['idBooking'] as int,
      bookingCode:
          json['booking_code'] as String? ?? json['bookingCode'] as String?,
      totalAmount: totalAmount,
      bookingStatus:
          json['booking_status'] as String? ??
          json['bookingStatus'] as String? ??
          'pending',
      paymentStatus:
          json['payment_status'] as String? ??
          json['paymentStatus'] as String? ??
          'unpaid',
    );
  }
}
