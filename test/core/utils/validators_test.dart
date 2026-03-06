import 'package:flutter_test/flutter_test.dart';
import 'package:sneak_fit/core/utils/validators.dart';

void main() {
  group('Validators', () {
    test('validateEmail should return error for null/empty', () {
      expect(Validators.validateEmail(null), 'Email cannot be empty');
      expect(Validators.validateEmail(''), 'Email cannot be empty');
    });

    test('validateEmail should return error for invalid email', () {
      expect(Validators.validateEmail('invalid-email'), 'Enter a valid email');
    });

    test('validateEmail should return null for valid email', () {
      expect(Validators.validateEmail('test@gmail.com'), isNull);
    });

    test('validatePassword should return error for short password', () {
      expect(Validators.validatePassword('123'), 'Password too short');
    });

    test('validatePassword should return null for valid password', () {
      expect(Validators.validatePassword('password123'), isNull);
    });
  });
}
