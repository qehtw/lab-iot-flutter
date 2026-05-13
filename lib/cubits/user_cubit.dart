import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/models/user.dart';
import '../core/repositories/auth_repository.dart';
import '../core/repositories/user_repository.dart';

sealed class UserState {}

final class UserLoading extends UserState {}

final class UserAuthenticated extends UserState {
  UserAuthenticated(this.user);
  final User user;
}

final class UserUnauthenticated extends UserState {}

final class UserError extends UserState {
  UserError(this.message);
  final String message;
}

class UserCubit extends Cubit<UserState> {
  UserCubit(this._authRepo, this._userRepo) : super(UserLoading());

  final AuthRepository _authRepo;
  final UserRepository _userRepo;

  Future<void> loadUser() async {
    emit(UserLoading());
    final user = await _authRepo.getCurrentUser();
    emit(user != null ? UserAuthenticated(user) : UserUnauthenticated());
  }

  Future<String?> login(String email, String password) async {
    emit(UserLoading());
    final (user, error) = await _authRepo.login(email, password);
    if (error != null) {
      emit(UserUnauthenticated());
      return error;
    }
    emit(UserAuthenticated(user!));
    return null;
  }

  Future<String?> register(User user) async {
    emit(UserLoading());
    final error = await _authRepo.register(user);
    if (error != null) {
      emit(UserUnauthenticated());
      return error;
    }
    final created = await _authRepo.getCurrentUser();
    emit(created != null ? UserAuthenticated(created) : UserUnauthenticated());
    return null;
  }

  Future<void> logout() async {
    await _authRepo.logout();
    emit(UserUnauthenticated());
  }

  Future<void> updateUser(User user) async {
    await _userRepo.update(user);
    emit(UserAuthenticated(user));
  }

  Future<void> deleteUser(String email) async {
    await _userRepo.delete(email);
    await _authRepo.logout();
    emit(UserUnauthenticated());
  }
}
