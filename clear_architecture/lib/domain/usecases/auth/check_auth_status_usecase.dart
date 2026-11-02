import '../../repositories/auth_repository.dart';
import '../../repositories/token_repository.dart';

class CheckAuthStatusUseCase {
  final AuthRepository _authRepository;
  final TokenRepository _tokenRepository;

  CheckAuthStatusUseCase(this._authRepository, this._tokenRepository);

  Future<bool> execute() async {
    final token = await _tokenRepository.readAccess();
    final user = _authRepository.currentUser;
    return token != null && user != null;
  }
}

