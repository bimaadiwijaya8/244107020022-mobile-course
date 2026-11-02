import '../../domain/entities/auth_session.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({AuthRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? AuthRemoteDataSourceImpl();

  final AuthRemoteDataSource _remoteDataSource;

  @override
  UserEntity? get currentUser => _remoteDataSource.currentUser;

  @override
  Stream<UserEntity?> get authStateChanges => _remoteDataSource.authStateChanges;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    return _remoteDataSource.login(email: email, password: password);
  }

  @override
  Future<AuthSession> register({
    required String email,
    required String password,
  }) async {
    return _remoteDataSource.register(email: email, password: password);
  }

  @override
  Future<void> logout() async {
    await _remoteDataSource.logout();
  }

  @override
  Future<String> refresh(String refreshToken) async {
    return _remoteDataSource.refresh(refreshToken);
  }
}

