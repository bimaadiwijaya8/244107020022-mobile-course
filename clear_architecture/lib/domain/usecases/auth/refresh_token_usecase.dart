import '../../repositories/auth_repository.dart';
import '../../repositories/token_repository.dart';

class RefreshTokenUseCase {
  final AuthRepository _authRepository;
  final TokenRepository _tokenRepository;

  RefreshTokenUseCase(this._authRepository, this._tokenRepository);

  Future<String> execute(String refreshToken) async {
    final renewed = await _authRepository.refresh(refreshToken);
    await _tokenRepository.save(access: renewed, refresh: refreshToken);
    return renewed;
  }
}

