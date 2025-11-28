class BookingSeatDto {
  const BookingSeatDto({required this.idSeats, this.price});

  final int idSeats;
  final double? price;

  Map<String, dynamic> toJson() {
    return {'idSeats': idSeats, if (price != null) 'price': price};
  }
}

class BookingProductDto {
  const BookingProductDto({
    required this.idProduct,
    required this.quantity,
    this.price,
  });

  final int idProduct;
  final int quantity;
  final double? price;

  Map<String, dynamic> toJson() {
    return {
      'idProduct': idProduct,
      'quantity': quantity,
      if (price != null) 'price': price,
    };
  }
}

class CreateBookingDto {
  const CreateBookingDto({
    required this.idShowtime,
    required this.totalAmount,
    this.idUsers,
    this.bookingStatus = 'pending',
    this.paymentStatus = 'unpaid',
    this.seats,
    this.products,
  });

  final int? idUsers;
  final int idShowtime;
  final double totalAmount;
  final String bookingStatus;
  final String paymentStatus;
  final List<BookingSeatDto>? seats;
  final List<BookingProductDto>? products;

  Map<String, dynamic> toJson() {
    return {
      if (idUsers != null) 'idUsers': idUsers,
      'idShowtime': idShowtime,
      'totalAmount': totalAmount.toInt(),
      'bookingStatus': bookingStatus,
      'paymentStatus': paymentStatus,
      'bookingDate': DateTime.now().toIso8601String(),
      if (seats != null) 'seats': seats!.map((s) => s.toJson()).toList(),
      if (products != null)
        'products': products!.map((p) => p.toJson()).toList(),
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
