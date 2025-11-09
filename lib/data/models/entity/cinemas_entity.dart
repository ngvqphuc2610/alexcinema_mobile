


import 'package:equatable/equatable.dart';

class CinemaEntity extends Equatable {
  const CinemaEntity({
    required this.id,
    required this.cinemaName,
    required this.address,
    required this.city,
    required this.status,
    this.description,
    this.image,
    this.contactNumber,
    this.email,
  });

  final int id;
  final String cinemaName;
  final String address;
  final String city;
  final String status;
  final String? description;
  final String? image;
  final String? contactNumber;
  final String? email;

  factory CinemaEntity.fromJson(Map<String, dynamic> json) {
    return CinemaEntity(
      id: json['id_cinema'] as int? ?? json['id'] as int? ?? 0,
      cinemaName: json['cinema_name'] as String? ?? json['cinemaName'] as String? ?? '',
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      description: json['description'] as String?,
      image: json['image'] as String? ?? json['imageUrl'] as String?,
      contactNumber: json['contact_number'] as String? ?? json['contactNumber'] as String?,
      email: json['email'] as String?,
      status: json['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_cinema': id,
      'cinema_name': cinemaName,
      'address': address,
      'city': city,
      'description': description,
      'image': image,
      'contact_number': contactNumber,
      'email': email,
      'status': status,
    };
  }

  CinemaEntity copyWith({
    String? cinemaName,
    String? address,
    String? city,
    String? status,
    String? description,
    String? image,
    String? contactNumber,
    String? email,
  }) {
    return CinemaEntity(
      id: id,
      cinemaName: cinemaName ?? this.cinemaName,
      address: address ?? this.address,
      city: city ?? this.city,
      status: status ?? this.status,
      description: description ?? this.description,
      image: image ?? this.image,
      contactNumber: contactNumber ?? this.contactNumber,
      email: email ?? this.email,
    );
  }

  @override
  List<Object?> get props => [
        id,
        cinemaName,
        address,
        city,
        description,
        image,
        contactNumber,
        email,
        status,
      ];
}
