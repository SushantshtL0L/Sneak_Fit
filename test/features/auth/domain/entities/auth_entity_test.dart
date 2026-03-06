import 'package:flutter_test/flutter_test.dart';
import 'package:sneak_fit/features/auth/domain/entities/auth_entity.dart';

void main() {
  group('AuthEntity', () {
    const tAuthEntity = AuthEntity(
      userId: '1',
      userName: 'testuser',
      name: 'Test User',
      email: 'test@gmail.com',
      password: 'password123',
      profileImage: 'image.jpg',
      token: 'jwt_token',
      role: 'user',
    );

    test('should hold correct values and support value equality', () {
      // Create a duplicate entity
      const tAuthEntityDuplicate = AuthEntity(
        userId: '1',
        userName: 'testuser',
        name: 'Test User',
        email: 'test@gmail.com',
        password: 'password123',
        profileImage: 'image.jpg',
        token: 'jwt_token',
        role: 'user',
      );

      // Assert
      expect(tAuthEntity, equals(tAuthEntityDuplicate));
      expect(tAuthEntity.email, 'test@gmail.com');
      expect(tAuthEntity.userName, 'testuser');
    });

    test('should return different hashcode for different values', () {
      const tDifferentEntity = AuthEntity(
        userId: '2',
        email: 'other@gmail.com',
      );

      expect(tAuthEntity == tDifferentEntity, isFalse);
    });
  });
}
