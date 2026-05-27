import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

// Auth state
sealed class AuthState {
  const AuthState();
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);
  final UserEntity user;
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

final class AuthError extends AuthState {
  const AuthError(this.message);
  final String message;
}

final class AuthMfaRequired extends AuthState {
  const AuthMfaRequired(this.resolver);
  final MultiFactorResolver resolver;
}

// Auth notifier
class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    final repo = ref.read(authRepositoryProvider);
    final userOrFailure = await repo.getCurrentUser();
    return userOrFailure.fold(
      (_) => const AuthUnauthenticated(),
      (user) => AuthAuthenticated(user),
    );
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncData(AuthLoading());
    try {
      final useCase = ref.read(signInUseCaseProvider);
      final result = await useCase(SignInParams(email: email, password: password));
      state = AsyncData(
        result.fold(
          (failure) => AuthError(failure.message),
          (user) => AuthAuthenticated(user),
        ),
      );
    } catch (e) {
      state = AsyncData(AuthError(e.toString()));
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
  }) async {
    state = const AsyncData(AuthLoading());
    try {
      final useCase = ref.read(registerUseCaseProvider);
      final result = await useCase(RegisterParams(
        email: email,
        password: password,
        name: name,
        phone: phone,
        role: role,
      ));
      state = AsyncData(
        result.fold(
          (failure) => AuthError(failure.message),
          (user) => AuthAuthenticated(user),
        ),
      );
    } catch (e) {
      state = AsyncData(AuthError(e.toString()));
    }
  }

  Future<void> signOut() async {
    state = const AsyncData(AuthLoading());
    final repo = ref.read(authRepositoryProvider);
    await repo.signOut();
    state = const AsyncData(AuthUnauthenticated());
  }

  Future<void> authenticateWithBiometrics() async {
    state = const AsyncData(AuthLoading());
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.authenticateWithBiometrics();
    result.fold(
      (failure) => state = AsyncData(AuthError(failure.message)),
      (success) {
        if (!success) state = const AsyncData(AuthUnauthenticated());
      },
    );
  }

  void clearError() {
    if (state.value is AuthError) {
      state = const AsyncData(AuthUnauthenticated());
    }
  }
}

// Providers — concrete implementations injected via get_it, exposed via provider
final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

// These providers wrap get_it so Riverpod and injectable coexist cleanly
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  throw UnimplementedError('Override in ProviderScope with get_it instance');
});

final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  throw UnimplementedError('Override in ProviderScope with get_it instance');
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  throw UnimplementedError('Override in ProviderScope with get_it instance');
});

// Current user derived provider
final currentUserProvider = Provider<UserEntity?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.maybeWhen(
    data: (state) => state is AuthAuthenticated ? state.user : null,
    orElse: () => null,
  );
});
