import 'package:flutter_test/flutter_test.dart';
import 'package:sneak_fit/features/auth/data/models/login_request.dart';

void main() {
  group('LoginRequest', () {
    test('toJson should return a valid Map', () {
      final tLoginRequest = LoginRequest(
        email: 'test@example.com',
        password: 'password123',
      );

      final result = tLoginRequest.toJson();

      final expectedMap = {
        'email': 'test@example.com',
        'password': 'password123',
      };

      expect(result, expectedMap);
    });
  });
}
