import 'package:equatable/equatable.dart';

enum InviteStatus { pending, accepted, expired, revoked }

class InviteEntity extends Equatable {
  const InviteEntity({
    required this.inviteId,
    required this.householdId,
    required this.createdByUid,
    required this.createdAt,
    required this.expiresAt,
    required this.status,
    this.acceptedByUid,
    this.acceptedAt,
  });

  final String inviteId;
  final String householdId;
  final String createdByUid;
  final DateTime createdAt;
  final DateTime expiresAt;
  final InviteStatus status;
  final String? acceptedByUid;
  final DateTime? acceptedAt;

  bool get isValid =>
      status == InviteStatus.pending && DateTime.now().isBefore(expiresAt);

  @override
  List<Object?> get props => [inviteId, householdId, status];
}
