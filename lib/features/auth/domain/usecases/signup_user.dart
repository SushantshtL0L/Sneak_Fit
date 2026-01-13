import '../entities/user.dart';
import '../repositories/user_repository.dart';

class SignupUser {
  final UserRepository repository;
  SignupUser(this.repository);

  Future<void> call(User user) async {
    await repository.signup(user);
  }
}
