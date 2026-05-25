class ServerException implements Exception {
  const ServerException([this.message = 'Server error occurred.']);
  final String message;
}

class NetworkException implements Exception {
  const NetworkException([this.message = 'No internet connection.']);
  final String message;
}

class AuthException implements Exception {
  const AuthException([this.message = 'Authentication failed.']);
  final String message;
}

class PermissionException implements Exception {
  const PermissionException([this.message = 'Permission denied.']);
  final String message;
}

class EncryptionException implements Exception {
  const EncryptionException([this.message = 'Encryption error.']);
  final String message;
}

class StorageException implements Exception {
  const StorageException([this.message = 'Local storage error.']);
  final String message;
}

class EmergencyException implements Exception {
  const EmergencyException([this.message = 'Emergency system error.']);
  final String message;
}
