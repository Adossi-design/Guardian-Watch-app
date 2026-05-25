import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../bloc/geofence_provider.dart';
import '../widgets/geofence_zone_card.dart';

class GeofenceZonesPage extends ConsumerStatefulWidget {
  const GeofenceZonesPage({super.key});

  @override
  ConsumerState<GeofenceZonesPage> createState() => _GeofenceZonesPageState();
}

class _GeofenceZonesPageState extends ConsumerState<GeofenceZonesPage> {
  GoogleMapController? _mapController;
  LatLng? _pendingCenter;
  double _pendingRadius = 200;
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final geofenceAsync = ref.watch(geofenceNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Safe zones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            tooltip: 'Live tracking',
            onPressed: () => context.push('/geofence/tracking'),
          ),
        ],
      ),
      body: geofenceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (state) => switch (state) {
          GeofencePermissionRequired() => _PermissionPrompt(
              onRequest: () => ref
                  .read(geofenceNotifierProvider.notifier)
                  .requestPermission(),
            ),
          GeofenceData(:final zones, :final currentLocation) => Column(
              children: [
                // Map
                SizedBox(
                  height: 280,
                  child: GoogleMap(
                    onMapCreated: (c) => _mapController = c,
                    initialCameraPosition: CameraPosition(
                      target: currentLocation != null
                          ? LatLng(currentLocation.latitude,
                              currentLocation.longitude)
                          : const LatLng(0, 0),
                      zoom: 15,
                    ),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    onTap: _onMapTap,
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
                      if (_pendingCenter != null)
                        Circle(
                          circleId: const CircleId('_pending'),
                          center: _pendingCenter!,
                          radius: _pendingRadius,
                          fillColor: Colors.green.withValues(alpha: 0.2),
                          strokeColor: Colors.green,
                          strokeWidth: 2,
                        ),
                    },
                    markers: {
                      if (_pendingCenter != null)
                        Marker(
                          markerId: const MarkerId('_pending'),
                          position: _pendingCenter!,
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueGreen),
                        ),
                    },
                  ),
                ),

                // Zone list
                Expanded(
                  child: zones.isEmpty
                      ? Center(
                          child: Text(
                            'Tap the map to add a safe zone',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemCount: zones.length,
                          itemBuilder: (_, i) => GeofenceZoneCard(
                            zone: zones[i],
                            onDelete: () =>
                                _confirmDelete(context, zones[i].id),
                          ),
                        ),
                ),
              ],
            ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }

  void _onMapTap(LatLng pos) {
    setState(() => _pendingCenter = pos);
    _showAddZoneSheet();
  }

  Future<void> _showAddZoneSheet() async {
    _nameController.clear();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('New safe zone',
                  style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Zone name',
                  hintText: 'e.g. Home, Work',
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('Radius: ${_pendingRadius.toInt()} m'),
                  Expanded(
                    child: Slider(
                      value: _pendingRadius,
                      min: 50,
                      max: 2000,
                      divisions: 39,
                      onChanged: (v) {
                        setModalState(() => _pendingRadius = v);
                        setState(() => _pendingRadius = v);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _savePendingZone,
                child: const Text('Save zone'),
              ),
              TextButton(
                onPressed: () {
                  setState(() => _pendingCenter = null);
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _savePendingZone() async {
    final center = _pendingCenter;
    if (center == null) return;
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    Navigator.pop(context);
    await ref.read(geofenceNotifierProvider.notifier).createZone(
          name: name,
          centerLat: center.latitude,
          centerLng: center.longitude,
          radiusMeters: _pendingRadius,
        );
    setState(() => _pendingCenter = null);
  }

  Future<void> _confirmDelete(BuildContext context, String zoneId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete zone'),
        content: const Text(
            'Alerts will no longer fire for this safe zone. Continue?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(geofenceNotifierProvider.notifier).deleteZone(zoneId);
    }
  }
}

class _PermissionPrompt extends StatelessWidget {
  const _PermissionPrompt({required this.onRequest});
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_off_outlined, size: 64),
              const SizedBox(height: 16),
              Text(
                'Location access needed',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'GuardianWatch needs location access to monitor safe zones and detect if you leave home.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: onRequest,
                child: const Text('Grant location access'),
              ),
            ],
          ),
        ),
      );
}
