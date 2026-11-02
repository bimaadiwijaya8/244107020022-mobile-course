import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user_entity.dart';
import 'dependency_injection.dart';

final currentUserProvider = Provider<UserEntity?>((ref) {
  // Watch auth state to update when user logs in/out
  ref.watch(authStateProvider);
  return ref.watch(getCurrentUserUseCaseProvider).execute();
});

final authStateProvider =
    AsyncNotifierProvider<AuthNotifier, bool>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    return ref.watch(checkAuthStatusUseCaseProvider).execute();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(loginUseCaseProvider)
          .execute(email: email, password: password);
      return true;
    });
  }

  Future<void> register(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(registerUseCaseProvider)
          .execute(email: email, password: password);
      return true;
    });
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    await ref.read(logoutUseCaseProvider).execute();
    state = const AsyncData(false);
  }
}

