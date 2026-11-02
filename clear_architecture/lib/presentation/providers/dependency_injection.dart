import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/push_notification_remote_datasource.dart';
import '../../data/datasources/token_local_datasource.dart';
import '../../data/network/api_client.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/push_notification_repository_impl.dart';
import '../../data/repositories/token_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/push_notification_repository.dart';
import '../../domain/repositories/token_repository.dart';
import '../../domain/usecases/auth/check_auth_status_usecase.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import '../../domain/usecases/notification/cancel_notification_usecase.dart';
import '../../domain/usecases/notification/show_local_notification_usecase.dart';

// Data Sources
final tokenLocalDataSourceProvider = Provider<TokenLocalDataSource>((ref) {
  return TokenLocalDataSourceImpl();
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl();
});

// Repositories
final tokenRepositoryProvider = Provider<TokenRepository>((ref) {
  return TokenRepositoryImpl(
    localDataSource: ref.watch(tokenLocalDataSourceProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
  );
});

final apiClientProvider = Provider<Dio>((ref) {
  final tokenRepo = ref.watch(tokenRepositoryProvider);
  final authRepo = ref.watch(authRepositoryProvider);
  return buildApiClient(tokenRepo, authRepo);
});

final pushNotificationRemoteDataSourceProvider =
    Provider<PushNotificationRemoteDataSource>((ref) {
  final dio = ref.watch(apiClientProvider);
  return PushNotificationRemoteDataSourceImpl(dioClient: dio);
});

final pushNotificationRepositoryProvider =
    Provider<PushNotificationRepository>((ref) {
  return PushNotificationRepositoryImpl(
    ref.watch(pushNotificationRemoteDataSourceProvider),
  );
});

// Use Cases
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(
    ref.watch(authRepositoryProvider),
    ref.watch(tokenRepositoryProvider),
  );
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(
    ref.watch(authRepositoryProvider),
    ref.watch(tokenRepositoryProvider),
  );
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(
    ref.watch(authRepositoryProvider),
    ref.watch(tokenRepositoryProvider),
  );
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(
    ref.watch(authRepositoryProvider),
  );
});

final checkAuthStatusUseCaseProvider = Provider<CheckAuthStatusUseCase>((ref) {
  return CheckAuthStatusUseCase(
    ref.watch(authRepositoryProvider),
    ref.watch(tokenRepositoryProvider),
  );
});

final showLocalNotificationUseCaseProvider =
    Provider<ShowLocalNotificationUseCase>((ref) {
  return ShowLocalNotificationUseCase(
    ref.watch(pushNotificationRepositoryProvider),
  );
});

final cancelNotificationUseCaseProvider =
    Provider<CancelNotificationUseCase>((ref) {
  return CancelNotificationUseCase(
    ref.watch(pushNotificationRepositoryProvider),
  );
});
