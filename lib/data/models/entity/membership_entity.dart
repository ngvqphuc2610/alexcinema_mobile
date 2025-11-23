import 'package:equatable/equatable.dart';

class MembershipEntity extends Equatable {
  const MembershipEntity({
    required this.id,
    required this.code,
    required this.title,
    required this.status,
    this.image,
    this.link,
    this.description,
    this.benefits,
    this.criteria,
  });

  final int id;
  final String code;
  final String title;
  final String status;
  final String? image;
  final String? link;
  final String? description;
  final String? benefits;
  final String? criteria;

  factory MembershipEntity.fromJson(Map<String, dynamic> json) {
    return MembershipEntity(
      id: json['id_membership'] as int? ?? json['id'] as int? ?? 0,
      code: json['code'] as String? ?? '',
      title: json['title'] as String? ?? '',
      image: json['image'] as String?,
      link: json['link'] as String?,
      description: json['description'] as String?,
      benefits: json['benefits'] as String?,
      criteria: json['criteria'] as String?,
      status: json['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_membership': id,
      'code': code,
      'title': title,
      'image': image,
      'link': link,
      'description': description,
      'benefits': benefits,
      'criteria': criteria,
      'status': status,
    };
  }

  @override
  List<Object?> get props => [id, code, title, status, image, link, description, benefits, criteria];
}
