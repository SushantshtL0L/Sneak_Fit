import 'package:flutter_test/flutter_test.dart';
import 'package:sneak_fit/core/error/failure.dart';

void main() {
  group('Failure Classes', () {
    test('LocalDatabaseFailure should have default message and support equality', () {
      const tFailure = LocalDatabaseFailure();
      const tFailureDuplicate = LocalDatabaseFailure();

      expect(tFailure.message, 'Local database operation failed');
      expect(tFailure, equals(tFailureDuplicate));
    });

    test('ApiFailure should hold message and statusCode and support equality', () {
      const tFailure = ApiFailure(message: 'Server Error', statusCode: 500);
      const tFailureDuplicate = ApiFailure(message: 'Server Error', statusCode: 500);

      expect(tFailure.message, 'Server Error');
      expect(tFailure.statusCode, 500);
      expect(tFailure, equals(tFailureDuplicate));
    });

    test('ApiFailure should be different if statusCode differs', () {
      const tFailure1 = ApiFailure(message: 'Error', statusCode: 400);
      const tFailure2 = ApiFailure(message: 'Error', statusCode: 404);

      expect(tFailure1 == tFailure2, isFalse);
    });
  });
}
