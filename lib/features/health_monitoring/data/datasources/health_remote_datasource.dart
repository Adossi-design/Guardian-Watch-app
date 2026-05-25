import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/security/encryption_service.dart';
import '../../domain/entities/health_anomaly.dart';
import '../../domain/entities/health_reading.dart';
import '../models/health_anomaly_model.dart';
import '../models/health_reading_model.dart';

@lazySingleton
class HealthRemoteDataSource {
  const HealthRemoteDataSource(this._firestore, this._encryption);

  final FirebaseFirestore _firestore;
  final EncryptionService _encryption;

  static const _readingsCol = 'health_events';
  static const _anomaliesCol = 'health_anomalies';

  Future<void> saveReading(HealthReading reading) async {
    final map = HealthReadingModel.fromEntity(reading).toMap();
    // Per spec: medical data encrypted at field level before any Firestore write
    map['value'] = await _encryption.encrypt(reading.value.toString());
    await _firestore.collection(_readingsCol).doc(reading.id).set(map);
  }

  Future<void> saveAnomaly(HealthAnomaly anomaly) async {
    final map = HealthAnomalyModel.fromEntity(anomaly).toMap();
    final readingMap = Map<String, dynamic>.from(map['reading'] as Map);
    readingMap['value'] = await _encryption.encrypt(anomaly.reading.value.toString());
    map['reading'] = readingMap;
    await _firestore.collection(_anomaliesCol).doc(anomaly.id).set(map);
  }

  Stream<List<HealthAnomaly>> watchAnomalies({
    required String householdId,
    int limit = 20,
  }) =>
      _firestore
          .collection(_anomaliesCol)
          .where('household_id', isEqualTo: householdId)
          .orderBy('detected_at', descending: true)
          .limit(limit)
          .snapshots()
          .asyncMap((s) => Future.wait(s.docs.map((d) => _decryptAnomaly(d.data()))));

  Stream<List<HealthReading>> watchRecentReadings({
    required String userId,
    required HealthReadingType type,
    int limit = 10,
  }) =>
      _firestore
          .collection(_readingsCol)
          .where('user_id', isEqualTo: userId)
          .where('type', isEqualTo: type.name)
          .orderBy('recorded_at', descending: true)
          .limit(limit)
          .snapshots()
          .asyncMap((s) => Future.wait(s.docs.map((d) => _decryptReading(d.data()))));

  Future<void> acknowledgeAnomaly({
    required String anomalyId,
    required String acknowledgedBy,
  }) =>
      _firestore.collection(_anomaliesCol).doc(anomalyId).update({
        'acknowledged_by': acknowledgedBy,
        'acknowledged_at': FieldValue.serverTimestamp(),
      });

  Future<HealthReading> _decryptReading(Map<String, dynamic> map) async {
    final m = Map<String, dynamic>.from(map);
    m['value'] = double.tryParse(await _encryption.decrypt(m['value'] as String)) ?? 0.0;
    return HealthReadingModel.fromMap(m);
  }

  Future<HealthAnomaly> _decryptAnomaly(Map<String, dynamic> map) async {
    final m = Map<String, dynamic>.from(map);
    final r = Map<String, dynamic>.from(m['reading'] as Map);
    r['value'] = double.tryParse(await _encryption.decrypt(r['value'] as String)) ?? 0.0;
    m['reading'] = r;
    return HealthAnomalyModel.fromMap(m);
  }
}
