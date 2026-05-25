import 'package:equatable/equatable.dart';

enum UserRole { primary, monitor, admin }

class UserEntity extends Equatable {
  const UserEntity({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.householdId,
    required this.createdAt,
    this.mfaEnabled = false,
    this.subscriptionTier = SubscriptionTier.free,
    this.schemaVersion = 1,
  });

  final String uid;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String householdId;
  final DateTime createdAt;
  final bool mfaEnabled;
  final SubscriptionTier subscriptionTier;
  final int schemaVersion;

  bool get isPrimary => role == UserRole.primary;
  bool get isMonitor => role == UserRole.monitor;
  bool get isAdmin => role == UserRole.admin;

  @override
  List<Object?> get props => [uid, name, email, phone, role, householdId, mfaEnabled];
}

enum SubscriptionTier { free, premium, family }
