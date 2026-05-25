import 'package:equatable/equatable.dart';

class LocationReading extends Equatable {
  const LocationReading({
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.timestamp,
  });

  final String userId;
  final double latitude;
  final double longitude;
  final double accuracyMeters;
  final DateTime timestamp;

  @override
  List<Object?> get props =>
      [userId, latitude, longitude, accuracyMeters, timestamp];
}
