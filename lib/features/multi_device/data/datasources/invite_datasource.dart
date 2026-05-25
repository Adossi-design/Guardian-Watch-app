import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/invite_entity.dart';
import '../models/invite_model.dart';

@lazySingleton
class InviteDataSource {
  InviteDataSource(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final Uuid _uuid = const Uuid();

  static const String _inviteCollection = 'invites';
  static const String _householdCollection = 'households';

  Future<InviteModel> createInvite(String householdId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw const AuthException('Not signed in.');

    final inviteId = _uuid.v4();
    final now = DateTime.now();
    // Single-use, expires in 48 hours — per spec Section 8
    final model = InviteModel(
      inviteId: inviteId,
      householdId: householdId,
      createdByUid: uid,
      createdAt: now,
      expiresAt: now.add(const Duration(hours: 48)),
      status: InviteStatus.pending,
    );

    await _firestore.collection(_inviteCollection).doc(inviteId).set(model.toMap());
    return model;
  }

  Future<InviteModel> getInvite(String inviteId) async {
    final doc = await _firestore.collection(_inviteCollection).doc(inviteId).get();
    if (!doc.exists) throw const ServerException('Invite not found or already used.');
    return InviteModel.fromFirestore(doc);
  }

  Future<void> acceptInvite(String inviteId, String monitorName) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw const AuthException('Not signed in.');

    final invite = await getInvite(inviteId);
    if (!invite.isValid) throw const ServerException('This invite has expired or already been used.');

    final batch = _firestore.batch();

    // Mark invite consumed — single-use, per spec
    batch.update(
      _firestore.collection(_inviteCollection).doc(inviteId),
      {
        'status': 'accepted',
        'accepted_by_uid': uid,
        'accepted_at': FieldValue.serverTimestamp(),
      },
    );

    // Add monitor to household — unlimited, per spec Section 1
    batch.update(
      _firestore.collection(_householdCollection).doc(invite.householdId),
      {
        'monitors': FieldValue.arrayUnion([
          {
            'uid': uid,
            'name': monitorName,
            'role': 'monitor',
            'invite_status': 'accepted',
            'joined_at': Timestamp.now(),
            'notifications_enabled': true,
            'priority_order': 99,
          }
        ]),
      },
    );

    // Update monitor's household_id
    batch.update(
      _firestore.collection('users').doc(uid),
      {'household_id': invite.householdId},
    );

    await batch.commit();
  }

  Future<List<Map<String, dynamic>>> getHouseholdMonitors(String householdId) async {
    final doc = await _firestore.collection(_householdCollection).doc(householdId).get();
    if (!doc.exists) return [];
    final data = doc.data()!;
    return List<Map<String, dynamic>>.from(data['monitors'] as List? ?? []);
  }

  Future<void> removeMonitor(String householdId, String monitorUid) async {
    final monitors = await getHouseholdMonitors(householdId);
    final updated = monitors.where((m) => m['uid'] != monitorUid).toList();
    await _firestore.collection(_householdCollection).doc(householdId).update({
      'monitors': updated,
    });
  }
}
