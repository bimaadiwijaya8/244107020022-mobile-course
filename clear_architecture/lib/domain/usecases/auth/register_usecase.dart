import '../../entities/auth_session.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/token_repository.dart';

class RegisterUseCase {
  final AuthRepository _authRepository;
  final TokenRepository _tokenRepository;

  RegisterUseCase(this._authRepository, this._tokenRepository);

  Future<AuthSession> execute({
    required String email,
    required String password,
  }) async {
    final session = await _authRepository.register(
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

