import '../entities/user.dart';

abstract class UserRepository {
  Future<void> signup(User user);
  Future<User?> login(String email, String password);
}
