import 'package:equatable/equatable.dart';

import '../../../data/models/dto/membership_dto.dart';

abstract class MembershipEvent extends Equatable {
  const MembershipEvent();

  @override
  List<Object?> get props => [];
}

class MembershipsRequested extends MembershipEvent {
  const MembershipsRequested({this.query});

  final MembershipQueryDto? query;

  @override
  List<Object?> get props => [query];
}
