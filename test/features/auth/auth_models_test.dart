import 'package:flutter_base_app/features/auth/models/auth.dart';
import 'package:flutter_base_app/features/auth/models/login.dart';
import 'package:flutter_base_app/features/auth/models/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Login.toJson serializes credentials', () {
    const login = Login(username: 'tester', password: 'secret');

    expect(login.toJson(), <String, dynamic>{
      'username': 'tester',
      'password': 'secret',
    });
  });

  test('User.fromJson builds a user model', () {
    final user = User.fromJson(<String, dynamic>{
      'id': 1,
      'username': 'tester',
      'email': 'tester@example.com',
      'name': 'Test User',
    });

    expect(user.id, '1');
    expect(user.username, 'tester');
    expect(user.email, 'tester@example.com');
    expect(user.name, 'Test User');
  });

  test('Auth.fromJson builds an auth model with permissions', () {
    final auth = Auth.fromJson(<String, dynamic>{
      'accessToken': 'token',
      'isAuthenticated': true,
      'user': <String, dynamic>{
        'id': 1,
        'username': 'tester',
      },
      'permissions': <String>['users:read', 'cities:read'],
    });

    expect(auth.accessToken, 'token');
    expect(auth.isAuthenticated, isTrue);
    expect(auth.user.username, 'tester');
    expect(auth.permissions, <String>['users:read', 'cities:read']);
  });
}
