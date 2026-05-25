import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../auth/presentation/bloc/auth_provider.dart';
import '../../domain/entities/geofence_breach.dart';
import '../bloc/geofence_provider.dart';

class LiveTrackingPage extends ConsumerStatefulWidget {
  const LiveTrackingPage({super.key});

  @override
  ConsumerState<LiveTrackingPage> createState() => _LiveTrackingPageState();
}

class _LiveTrackingPageState extends ConsumerState<LiveTrackingPage> {
  GoogleMapController? _mapController;
  bool _followLocation = true;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final geofenceAsync = ref.watch(geofenceNotifierProvider);
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live tracking'),
        actions: [
          IconButton(
            icon: Icon(_followLocation
                ? Icons.gps_fixed
                : Icons.gps_not_fixed),
            tooltip: 'Centre on location',
            onPressed: () => setState(() => _followLocation = true),
          ),
        ],
      ),
      body: geofenceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (state) {
          if (state is! GeofenceData) {
            return const Center(child: Text('No data available'));
          }

          final location = state.currentLocation;
          final zones = state.zones;
          final breaches = state.recentBreaches;

          if (_followLocation && location != null) {
            _mapController?.animateCamera(
              CameraUpdate.newLatLng(
                  LatLng(location.latitude, location.longitude)),
            );
          }

          return Column(
            children: [
              Expanded(
                flex: 3,
                child: GoogleMap(
                  onMapCreated: (c) => _mapController = c,
                  initialCameraPosition: CameraPosition(
                    target: location != null
                        ? LatLng(location.latitude, location.longitude)
                        : const LatLng(0, 0),
                    zoom: 15,
                  ),
                  myLocationEnabled: true,
                  onCameraMoveStarted: () =>
                      setState(() => _followLocation = false),
                  circles: {
                    for (final z in zones)
                      Circle(
                        circleId: CircleId(z.id),
                        center: LatLng(z.centerLat, z.centerLng),
                        radius: z.radiusMeters,
                        fillColor: Colors.blue.withValues(alpha: 0.15),
                        strokeColor: Colors.blue,
                        strokeWidth: 2,
                      ),
                  },
                  markers: {
                    if (location != null)
                      Marker(
                        markerId: const MarkerId('_user'),
                        position:
                            LatLng(location.latitude, location.longitude),
                        infoWindow: InfoWindow(
                          title: user?.name ?? 'Guardian',
                          snippet: 'Accuracy: ${location.accuracyMeters.toInt()} m',
                        ),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueAzure),
                      ),
                  },
                ),
              ),

              // Recent breach events
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Text('Recent activity',
                          style: theme.textTheme.titleSmall),
                    ),
                    Expanded(
                      child: breaches.isEmpty
                          ? Center(
                              child: Text(
                                'No zone activity yet',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: breaches.length,
                              itemBuilder: (_, i) =>
                                  _BreachTile(breach: breaches[i]),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BreachTile extends StatelessWidget {
  const _BreachTile({required this.breach});
  final GeofenceBreach breach;

  @override
  Widget build(BuildContext context) {
    final isExit = breach.type == BreachType.exit;
    final theme = Theme.of(context);

    return ListTile(
      dense: true,
      leading: Icon(
        isExit ? Icons.logout : Icons.login,
        color: breach.isWandering
            ? Colors.red
            : (isExit ? Colors.orange : Colors.green),
        size: 20,
      ),
      title: Text(
        breach.isWandering
            ? '⚠️ Wandering detected'
            : '${breach.type.displayName}: ${breach.zoneName}',
        style: theme.textTheme.bodySmall,
      ),
      subtitle: Text(
        _formatTime(breach.timestamp),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  static String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    return '${diff.inHours} h ago';
  }
}
