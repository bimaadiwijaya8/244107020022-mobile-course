import '../../entities/auth_session.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/token_repository.dart';

class LoginUseCase {
  final AuthRepository _authRepository;
  final TokenRepository _tokenRepository;

  LoginUseCase(this._authRepository, this._tokenRepository);

  Future<AuthSession> execute({
    required String email,
    required String password,
  }) async {
    final session = await _authRepository.login(
      email: email,
      password: password,
    );
    await _tokenRepository.save(
      access: session.access,
      refresh: session.refresh,
    );
    return session;
  }
}

