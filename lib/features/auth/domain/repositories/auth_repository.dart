import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract interface class AuthRepository {
  Stream<UserEntity?> get authStateChanges;

  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
  });

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, void>> sendPasswordResetEmail(String email);

  Future<Either<Failure, UserEntity>> getCurrentUser();

  Future<Either<Failure, bool>> verifyMfaCode(String code);

  Future<Either<Failure, String>> enrollMfa();

  Future<Either<Failure, bool>> authenticateWithBiometrics();

  Future<Either<Failure, void>> updateFcmToken(String token);
}
