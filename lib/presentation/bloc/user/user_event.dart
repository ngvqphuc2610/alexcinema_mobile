import 'package:equatable/equatable.dart';

import '../../../data/models/dto/user_dto.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class UsersRequested extends UserEvent {
  const UsersRequested({this.query});

  final UserQueryDto? query;

  @override
  List<Object?> get props => [query];
}

class UserUpdated extends UserEvent {
  const UserUpdated(this.id, this.payload);

  final int id;
  final UserUpdateDto payload;

  @override
  List<Object?> get props => [id, payload];
}

class UserPasswordUpdated extends UserEvent {
  const UserPasswordUpdated(this.id, this.payload);

  final int id;
  final ChangePasswordDto payload;

  @override
  List<Object?> get props => [id, payload];
}

class UserDeleted extends UserEvent {
  const UserDeleted(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}
