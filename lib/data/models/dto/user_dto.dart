class UserQueryDto {
  const UserQueryDto({
    this.page,
    this.limit,
    this.search,
  });

  final int? page;
  final int? limit;
  final String? search;

  Map<String, String> toQueryParameters() {
    final map = <String, String>{};
    if (page != null) {
      map['page'] = '$page';
    }
    if (limit != null) {
      map['limit'] = '$limit';
    }
    if (search?.isNotEmpty == true) {
      map['search'] = search!.trim();
    }
    return map;
  }
}

class UserUpdateDto {
  UserUpdateDto({
    this.username,
    this.email,
    this.fullName,
    this.phoneNumber,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.profileImage,
    this.role,
    this.status,
  });

  final String? username;
  final String? email;
  final String? fullName;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? address;
  final String? profileImage;
  final String? role;
  final String? status;

  Map<String, dynamic> toJson() {
    return {
      'username': username?.trim(),
      'email': email?.trim(),
      'fullName': fullName?.trim(),
      'phoneNumber': phoneNumber?.trim(),
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender?.trim(),
      'address': address?.trim(),
      'profileImage': profileImage,
      'role': role?.trim(),
      'status': status?.trim(),
    }..removeWhere((_, value) => value == null);
  }
}

class ChangePasswordDto {
  ChangePasswordDto({
    required this.newPassword,
  });

  final String newPassword;

  Map<String, dynamic> toJson() {
    return {
      'newPassword': newPassword,
    };
  }
}
