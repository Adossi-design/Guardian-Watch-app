import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.name,
    required super.email,
    required super.phone,
    required super.role,
    required super.householdId,
    required super.createdAt,
    super.mfaEnabled,
    super.subscriptionTier,
    super.schemaVersion,
  });

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserModel(
      uid: doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      role: _parseRole(data['role'] as String?),
      householdId: data['household_id'] as String? ?? '',
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      mfaEnabled: data['mfa_enabled'] as bool? ?? false,
      subscriptionTier: _parseTier(data['subscription_tier'] as String?),
      schemaVersion: data['schema_version'] as int? ?? 1,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      role: _parseRole(map['role'] as String?),
      householdId: map['household_id'] as String? ?? '',
      createdAt: map['created_at'] is Timestamp
          ? (map['created_at'] as Timestamp).toDate()
          : DateTime.now(),
      mfaEnabled: map['mfa_enabled'] as bool? ?? false,
      subscriptionTier: _parseTier(map['subscription_tier'] as String?),
      schemaVersion: map['schema_version'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role.name,
        'household_id': householdId,
        'created_at': Timestamp.fromDate(createdAt),
        'mfa_enabled': mfaEnabled,
        'subscription_tier': subscriptionTier.name,
        'schema_version': schemaVersion,
        'last_seen': FieldValue.serverTimestamp(),
      };

  static UserRole _parseRole(String? value) => switch (value) {
        'primary' => UserRole.primary,
        'monitor' => UserRole.monitor,
        'admin' => UserRole.admin,
        _ => UserRole.monitor,
      };

  static SubscriptionTier _parseTier(String? value) => switch (value) {
        'premium' => SubscriptionTier.premium,
        'family' => SubscriptionTier.family,
        _ => SubscriptionTier.free,
      };
}
