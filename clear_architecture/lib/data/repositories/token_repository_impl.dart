import '../../domain/repositories/token_repository.dart';
import '../datasources/token_local_datasource.dart';

class TokenRepositoryImpl implements TokenRepository {
  TokenRepositoryImpl({TokenLocalDataSource? localDataSource})
      : _localDataSource = localDataSource ?? TokenLocalDataSourceImpl();

  final TokenLocalDataSource _localDataSource;

  @override
  Future<void> save({
    required String access,
    required String refresh,
  }) {
    return _localDataSource.saveTokens(access: access, refresh: refresh);
  }

  @override
  Future<String?> readAccess() => _localDataSource.getAccessToken();

  @override
  Future<String?> readRefresh() => _localDataSource.getRefreshToken();

  @override
  Future<void> clear() => _localDataSource.clearTokens();
}

