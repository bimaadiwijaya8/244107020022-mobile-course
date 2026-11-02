import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository _authRepository;

  GetCurrentUserUseCase(this._authRepository);

  UserEntity? execute() {
    return _authRepository.currentUser;
  }
}

