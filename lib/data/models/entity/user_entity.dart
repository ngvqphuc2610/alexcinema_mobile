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
    String? _stringify(dynamic value) {
      if (value == null) return null;
      if (value is String) return value;
      if (value is List) return value.join(',');
      return value.toString();
    }

    return UserEntity(
      id: json['id_users'] as int? ?? json['id'] as int? ?? 0,
      username: _stringify(json['username']) ?? '',
      email: _stringify(json['email']) ?? '',
      fullName: _stringify(json['full_name'] ?? json['fullName']) ?? '',
      role: _stringify(json['role']) ?? 'user',
      status: _stringify(json['status']) ?? 'active',
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updated_at']) ?? DateTime.now(),
      phoneNumber: _stringify(json['phone_number'] ?? json['phoneNumber']),
      dateOfBirth: _parseDate(json['date_of_birth'] ?? json['dateOfBirth']),
      gender: _stringify(json['gender']),
      address: _stringify(json['address']),
      profileImage: _stringify(json['profile_image'] ?? json['profileImage']),
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
