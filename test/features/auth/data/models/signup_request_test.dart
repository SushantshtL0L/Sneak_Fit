import 'package:flutter_test/flutter_test.dart';
import 'package:sneak_fit/features/auth/data/models/signup_request.dart';

void main() {
  group('SignupRequest', () {
    test('toJson should return a valid Map', () {
      final tSignupRequest = SignupRequest(
        email: 'newuser@example.com',
        password: 'password123',
        username: 'newuser',
      );

      final result = tSignupRequest.toJson();

      final expectedMap = {
        'email': 'newuser@example.com',
        'password': 'password123',
        'username': 'newuser',
      };

      expect(result, expectedMap);
    });
  });
}
