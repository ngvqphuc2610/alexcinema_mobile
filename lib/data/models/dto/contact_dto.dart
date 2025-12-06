class CreateContactDto {
  const CreateContactDto({
    required this.name,
    required this.email,
    required this.subject,
    required this.message,
    this.idStaff,
    this.status,
  });

  final String name;
  final String email;
  final String subject;
  final String message;
  final int? idStaff;
  final String? status;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'subject': subject,
      'message': message,
      if (idStaff != null) 'idStaff': idStaff,
      if (status != null) 'status': status,
    };
  }
}

class UpdateContactDto {
  const UpdateContactDto({
    this.idStaff,
    this.subject,
    this.message,
    this.status,
    this.reply,
    this.replyDate,
  });

  final int? idStaff;
  final String? subject;
  final String? message;
  final String? status;
  final String? reply;
  final DateTime? replyDate;

  Map<String, dynamic> toJson() {
    return {
      if (idStaff != null) 'idStaff': idStaff,
      if (subject != null) 'subject': subject,
      if (message != null) 'message': message,
      if (status != null) 'status': status,
      if (reply != null) 'reply': reply,
      if (replyDate != null) 'replyDate': replyDate!.toIso8601String(),
    };
  }
}

class ContactQueryDto {
  const ContactQueryDto({
    this.page,
    this.limit,
    this.status,
    this.staffId,
    this.search,
  });

  final int? page;
  final int? limit;
  final String? status;
  final int? staffId;
  final String? search;

  Map<String, String> toQueryParameters() {
    final params = <String, String>{};
    if (page != null) params['page'] = page.toString();
    if (limit != null) params['limit'] = limit.toString();
    if (status != null) params['status'] = status!;
    if (staffId != null) params['staffId'] = staffId.toString();
    if (search != null) params['search'] = search!;
    return params;
  }
}
