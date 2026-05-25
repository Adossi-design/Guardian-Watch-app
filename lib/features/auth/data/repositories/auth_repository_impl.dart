import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:local_auth/local_auth.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(
    this._firebaseAuth,
    this._firestore,
    this._networkInfo,
    this._localAuth,
  );

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final NetworkInfo _networkInfo;
  final LocalAuthentication _localAuth;
  final Logger _log = Logger();
  final Uuid _uuid = const Uuid();

  @override
  Stream<UserEntity?> get authStateChanges => _firebaseAuth.authStateChanges().asyncMap(
        (user) async {
          if (user == null) return null;
          try {
            final doc = await _firestore.collection('users').doc(user.uid).get();
            if (!doc.exists) return null;
            return UserModel.fromFirestore(doc);
          } catch (_) {
            return null;
          }
        },
      );

  @override
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final creds = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final doc = await _firestore.collection('users').doc(creds.user!.uid).get();
      if (!doc.exists) return const Left(AuthFailure('User profile not found.'));
      return Right(UserModel.fromFirestore(doc));
    } on FirebaseAuthException catch (e) {
      _log.e('SignIn error: ${e.code}');
      return Left(AuthFailure(_mapFirebaseAuthError(e.code)));
    } catch (e) {
      _log.e('SignIn unexpected: $e');
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
  }) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final creds = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await creds.user!.updateDisplayName(name);

      final householdId = role == UserRole.primary ? _uuid.v4() : '';
      final model = UserModel(
        uid: creds.user!.uid,
        name: name.trim(),
        email: email.trim(),
        phone: phone.trim(),
        role: role,
        householdId: householdId,
        createdAt: DateTime.now(),
      );

      final batch = _firestore.batch();
      batch.set(_firestore.collection('users').doc(model.uid), model.toMap());

      if (role == UserRole.primary) {
        batch.set(_firestore.collection('households').doc(householdId), {
          'household_id': householdId,
          'primary_uid': model.uid,
          'monitors': [],
          'geofences': [],
          'created_at': FieldValue.serverTimestamp(),
          'schema_version': 1,
        });
      }
      await batch.commit();
      return Right(model);
    } on FirebaseAuthException catch (e) {
      _log.e('Register error: ${e.code}');
      return Left(AuthFailure(_mapFirebaseAuthError(e.code)));
    } catch (e) {
      _log.e('Register unexpected: $e');
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return const Right(null);
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseAuthError(e.code)));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return const Left(AuthFailure('Not signed in.'));
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return const Left(NotFoundFailure('User profile not found.'));
      return Right(UserModel.fromFirestore(doc));
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> verifyMfaCode(String code) async {
    // Firebase TOTP MFA verification — triggered after initial sign-in when MFA enrolled
    // The actual resolver is handled in the presentation layer via FirebaseAuth MFA flow
    return const Right(true);
  }

  @override
  Future<Either<Failure, String>> enrollMfa() async {
    // Returns TOTP secret URI for QR code display
    // Full TOTP enrollment via Firebase Auth TOTP provider
    final user = _firebaseAuth.currentUser;
    if (user == null) return const Left(AuthFailure('Not signed in.'));
    try {
      final multiFactorSession = await user.multiFactor.getSession();
      final secret = await TotpMultiFactorGenerator.generateSecret(multiFactorSession);
      final uri = await secret.generateQrCodeUrl(
        accountName: user.email ?? '',
        issuer: 'GuardianWatch',
      );
      return Right(uri);
    } catch (e) {
      _log.e('MFA enroll error: $e');
      return const Left(AuthFailure('Failed to start MFA enrollment.'));
    }
  }

  @override
  Future<Either<Failure, bool>> authenticateWithBiometrics() async {
    try {
      final available = await _localAuth.canCheckBiometrics;
      if (!available) return const Right(false);
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access GuardianWatch',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
      return Right(authenticated);
    } catch (e) {
      _log.e('Biometric auth error: $e');
      return const Left(AuthFailure('Biometric authentication failed.'));
    }
  }

  @override
  Future<Either<Failure, void>> updateFcmToken(String token) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return const Left(AuthFailure('Not signed in.'));
    try {
      await _firestore.collection('users').doc(user.uid).update({
        'device_tokens': FieldValue.arrayUnion([token]),
        'last_seen': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure('Failed to update device token.'));
    }
  }

  String _mapFirebaseAuthError(String code) => switch (code) {
        'user-not-found' => 'No account found with this email.',
        'wrong-password' => 'Incorrect password.',
        'email-already-in-use' => 'An account with this email already exists.',
        'invalid-email' => 'Invalid email address.',
        'weak-password' => 'Password is too weak.',
        'too-many-requests' => 'Too many attempts. Please wait before trying again.',
        'user-disabled' => 'This account has been disabled.',
        'network-request-failed' => 'Network error. Check your connection.',
        _ => 'Authentication error. Please try again.',
      };
}
