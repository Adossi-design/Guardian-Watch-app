import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/invite_entity.dart';

class InviteModel extends InviteEntity {
  const InviteModel({
    required super.inviteId,
    required super.householdId,
    required super.createdByUid,
    required super.createdAt,
    required super.expiresAt,
    required super.status,
    super.acceptedByUid,
    super.acceptedAt,
  });

  factory InviteModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return InviteModel(
      inviteId: doc.id,
      householdId: d['household_id'] as String,
      createdByUid: d['created_by_uid'] as String,
      createdAt: (d['created_at'] as Timestamp).toDate(),
      expiresAt: (d['expires_at'] as Timestamp).toDate(),
      status: _parseStatus(d['status'] as String?),
      acceptedByUid: d['accepted_by_uid'] as String?,
      acceptedAt: d['accepted_at'] != null
          ? (d['accepted_at'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'invite_id': inviteId,
        'household_id': householdId,
        'created_by_uid': createdByUid,
        'created_at': Timestamp.fromDate(createdAt),
        'expires_at': Timestamp.fromDate(expiresAt),
        'status': status.name,
        if (acceptedByUid != null) 'accepted_by_uid': acceptedByUid,
        if (acceptedAt != null) 'accepted_at': Timestamp.fromDate(acceptedAt!),
      };

  static InviteStatus _parseStatus(String? v) => switch (v) {
        'accepted' => InviteStatus.accepted,
        'expired' => InviteStatus.expired,
        'revoked' => InviteStatus.revoked,
        _ => InviteStatus.pending,
      };
}
