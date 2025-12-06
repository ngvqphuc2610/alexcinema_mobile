import 'package:equatable/equatable.dart';

class ContactEntity extends Equatable {
  const ContactEntity({
    this.id,
    required this.name,
    required this.email,
    required this.subject,
    required this.message,
    this.status,
    this.contactDate,
    this.reply,
    this.replyDate,
    this.staffId,
  });

  final int? id;
  final String name;
  final String email;
  final String subject;
  final String message;
  final String? status;
  final DateTime? contactDate;
  final String? reply;
  final DateTime? replyDate;
  final int? staffId;

  factory ContactEntity.fromJson(Map<String, dynamic> json) {
    return ContactEntity(
      id: json['id_contact'] as int?,
      name: json['name'] as String,
      email: json['email'] as String,
      subject: json['subject'] as String,
      message: json['message'] as String,
      status: json['status'] as String?,
      contactDate: _parseDate(json['contact_date']),
      reply: json['reply'] as String?,
      replyDate: _parseDate(json['reply_date']),
      staffId: json['id_staff'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id_contact': id,
      'name': name,
      'email': email,
      'subject': subject,
      'message': message,
      if (status != null) 'status': status,
      if (contactDate != null) 'contact_date': contactDate!.toIso8601String(),
      if (reply != null) 'reply': reply,
      if (replyDate != null) 'reply_date': replyDate!.toIso8601String(),
      if (staffId != null) 'id_staff': staffId,
    };
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
        name,
        email,
        subject,
        message,
        status,
        contactDate,
        reply,
        replyDate,
        staffId,
      ];
}
