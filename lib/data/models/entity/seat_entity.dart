class SeatEntity {
  final int idSeats;
  final int? idScreen;
  final int? idSeatType;
  final String seatRow;
  final int seatNumber;
  final String? status;
  final SeatTypeEntity? seatType;

  SeatEntity({
    required this.idSeats,
    this.idScreen,
    this.idSeatType,
    required this.seatRow,
    required this.seatNumber,
    this.status,
    this.seatType,
  });

  factory SeatEntity.fromJson(Map<String, dynamic> json) {
    return SeatEntity(
      idSeats: json['id_seats'] as int,
      idScreen: json['id_screen'] as int?,
      idSeatType: json['id_seattype'] as int?,
      seatRow: json['seat_row'] as String,
      seatNumber: json['seat_number'] as int,
      status: json['status'] as String?,
      seatType: json['seat_type'] != null
          ? SeatTypeEntity.fromJson(json['seat_type'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_seats': idSeats,
      'id_screen': idScreen,
      'id_seattype': idSeatType,
      'seat_row': seatRow,
      'seat_number': seatNumber,
      'status': status,
      if (seatType != null) 'seat_type': seatType!.toJson(),
    };
  }

  String get seatLabel => '$seatRow$seatNumber';

  bool get isActive => status == 'active';
  bool get isInactive => status == 'inactive';
}

class SeatTypeEntity {
  final int idSeatType;
  final String typeName;
  final double priceMultiplier;
  final String? description;
  final String? iconUrl;

  SeatTypeEntity({
    required this.idSeatType,
    required this.typeName,
    required this.priceMultiplier,
    this.description,
    this.iconUrl,
  });

  factory SeatTypeEntity.fromJson(Map<String, dynamic> json) {
    return SeatTypeEntity(
      idSeatType: json['id_seattype'] as int,
      typeName: json['type_name'] as String,
      priceMultiplier: (json['price_multiplier'] is String)
          ? double.parse(json['price_multiplier'] as String)
          : (json['price_multiplier'] as num).toDouble(),
      description: json['description'] as String?,
      iconUrl: json['icon_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_seattype': idSeatType,
      'type_name': typeName,
      'price_multiplier': priceMultiplier,
      'description': description,
      'icon_url': iconUrl,
    };
  }

  bool get isVip => typeName.toLowerCase().contains('vip');
  bool get isDouble => typeName.toLowerCase().contains('double') || 
                       typeName.toLowerCase().contains('đôi');
}

