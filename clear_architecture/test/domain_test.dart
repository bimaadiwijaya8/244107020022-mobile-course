import 'package:flutter_test/flutter_test.dart';
import 'package:week_6_authentication_security_fcm/domain/entities/auth_session.dart';
import 'package:week_6_authentication_security_fcm/domain/entities/user_entity.dart';
import 'package:week_6_authentication_security_fcm/domain/repositories/auth_repository.dart';
import 'package:week_6_authentication_security_fcm/domain/repositories/token_repository.dart';
import 'package:week_6_authentication_security_fcm/domain/usecases/auth/check_auth_status_usecase.dart';
import 'package:week_6_authentication_security_fcm/domain/usecases/auth/login_usecase.dart';
import 'package:week_6_authentication_security_fcm/domain/usecases/auth/logout_usecase.dart';
import 'package:week_6_authentication_security_fcm/domain/usecases/auth/register_usecase.dart';

class FakeAuthRepository implements AuthRepository {
  UserEntity? user;

  @override
  UserEntity? get currentUser => user;

  @override
  Stream<UserEntity?> get authStateChanges => Stream.value(user);

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    user = UserEntity(uid: 'user123', email: email);
    return const AuthSession(access: 'fake_access', refresh: 'fake_refresh');
  }

  @override
  Future<AuthSession> register({
    required String email,
    required String password,
  }) async {
    user = UserEntity(uid: 'user123', email: email);
    return const AuthSession(access: 'fake_access', refresh: 'fake_refresh');
  }

  @override
  Future<void> logout() async {
    user = null;
  }

  @override
  Future<String> refresh(String refreshToken) async => 'fresh_access';
}

class FakeTokenRepository implements TokenRepository {
  String? access;
  String? refresh;

  @override
  Future<void> save({required String access, required String refresh}) async {
    this.access = access;
    this.refresh = refresh;
  }

  @override
  Future<String?> readAccess() async => access;

  @override
  Future<String?> readRefresh() async => refresh;

  @override
  Future<void> clear() async {
    access = null;
    refresh = null;
  }
}

void main() {
  group('Domain Use Cases Tests (SOLID & Clean Architecture)', () {
    late FakeAuthRepository authRepo;
    late FakeTokenRepository tokenRepo;

    setUp(() {
      authRepo = FakeAuthRepository();
      tokenRepo = FakeTokenRepository();
    });

    test('LoginUseCase menyimpan token dan mengembalikan session', () async {
      final loginUseCase = LoginUseCase(authRepo, tokenRepo);

      final session = await loginUseCase.execute(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(session.access, 'fake_access');
      expect(await tokenRepo.readAccess(), 'fake_access');
      expect(await tokenRepo.readRefresh(), 'fake_refresh');
      expect(authRepo.currentUser?.email, 'test@example.com');
    });

    test('RegisterUseCase mendaftarkan user dan menyimpan token', () async {
      final registerUseCase = RegisterUseCase(authRepo, tokenRepo);

      final session = await registerUseCase.execute(
        email: 'register@example.com',
        password: 'password123',
      );

      expect(session.access, 'fake_access');
      expect(await tokenRepo.readAccess(), 'fake_access');
      expect(authRepo.currentUser?.email, 'register@example.com');
    });

    test('LogoutUseCase membersihkan token dan sign out akun', () async {
      await tokenRepo.save(access: 'token', refresh: 'refresh');
      authRepo.user = const UserEntity(uid: '123', email: 'test@example.com');

      final logoutUseCase = LogoutUseCase(authRepo, tokenRepo);
      await logoutUseCase.execute();

      expect(await tokenRepo.readAccess(), isNull);
      expect(await tokenRepo.readRefresh(), isNull);
      expect(authRepo.currentUser, isNull);
    });

    test('CheckAuthStatusUseCase mengembalikan true hanya jika token dan user ada', () async {
      final checkAuthStatus = CheckAuthStatusUseCase(authRepo, tokenRepo);

      expect(await checkAuthStatus.execute(), isFalse);

      await tokenRepo.save(access: 'token', refresh: 'refresh');
      expect(await checkAuthStatus.execute(), isFalse);

      authRepo.user = const UserEntity(uid: '123', email: 'test@example.com');
      expect(await checkAuthStatus.execute(), isTrue);
    });
  });
}

