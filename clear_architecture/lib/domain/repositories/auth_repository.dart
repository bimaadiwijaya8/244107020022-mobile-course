import '../entities/auth_session.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  UserEntity? get currentUser;
  Stream<UserEntity?> get authStateChanges;

  Future<AuthSession> login({
    required String email,
    required String password,
  });

  Future<AuthSession> register({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<String> refresh(String refreshToken);
}

