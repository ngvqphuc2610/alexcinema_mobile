import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.role,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.phoneNumber,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.profileImage,
    this.twoFactorEnabled = false,
  });

  final int id;
  final String username;
  final String email;
  final String fullName;
  final String role;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? address;
  final String? profileImage;
  final bool twoFactorEnabled;

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id_users'] as int? ?? json['id'] as int? ?? 0,
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ?? json['fullName'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
      status: json['status'] as String? ?? 'active',
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updated_at']) ?? DateTime.now(),
      phoneNumber: json['phone_number'] as String? ?? json['phoneNumber'] as String?,
      dateOfBirth: _parseDate(json['date_of_birth'] ?? json['dateOfBirth']),
      gender: json['gender'] as String?,
      address: json['address'] as String?,
      profileImage: json['profile_image'] as String? ?? json['profileImage'] as String?,
      twoFactorEnabled: json['two_factor_enabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_users': id,
      'username': username,
      'email': email,
      'full_name': fullName,
      'role': role,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'phone_number': phoneNumber,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'address': address,
      'profile_image': profileImage,
      'two_factor_enabled': twoFactorEnabled,
    };
  }

  UserEntity copyWith({
    String? username,
    String? email,
    String? fullName,
    String? role,
    String? status,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? gender,
    String? address,
    String? profileImage,
    bool? twoFactorEnabled,
  }) {
    return UserEntity(
      id: id,
      username: username ?? this.username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      profileImage: profileImage ?? this.profileImage,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  @override
  List<Object?> get props => [
        id,
        username,
        email,
        fullName,
        role,
        status,
        createdAt,
        updatedAt,
        phoneNumber,
        dateOfBirth,
        gender,
        address,
        profileImage,
        twoFactorEnabled,
      ];
}
