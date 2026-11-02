import '../../repositories/auth_repository.dart';
import '../../repositories/token_repository.dart';

class LogoutUseCase {
  final AuthRepository _authRepository;
  final TokenRepository _tokenRepository;

  LogoutUseCase(this._authRepository, this._tokenRepository);

  Future<void> execute() async {
    await _authRepository.logout();
    await _tokenRepository.clear();
  }
}

