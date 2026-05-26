import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure([this.message = '']);
  final String message;

  @override
  List<Object?> get props => [message];
}

final class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred.']);
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

final class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed.']);
}

final class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Permission denied.']);
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Resource not found.']);
}

final class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Invalid input.']);
}

final class EncryptionFailure extends Failure {
  const EncryptionFailure([super.message = 'Encryption error.']);
}

final class StorageFailure extends Failure {
  const StorageFailure([super.message = 'Local storage error.']);
}

final class EmergencyFailure extends Failure {
  const EmergencyFailure([super.message = 'Emergency system error.']);
}

final class GeofenceFailure extends Failure {
  const GeofenceFailure([super.message = 'Geofence error.']);
}

final class VoiceAIFailure extends Failure {
  const VoiceAIFailure([super.message = 'Voice AI error.']);
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'An unexpected error occurred.']);
}
