import 'package:flutter/material.dart';
import '../../domain/entities/geofence_zone.dart';

class GeofenceZoneCard extends StatelessWidget {
  const GeofenceZoneCard({
    super.key,
    required this.zone,
    this.onDelete,
    this.onTap,
  });

  final GeofenceZone zone;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = zone.radiusMeters >= 1000
        ? '${(zone.radiusMeters / 1000).toStringAsFixed(1)} km'
        : '${zone.radiusMeters.toInt()} m';

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.location_on_rounded,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          zone.name,
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Radius: $radius',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: onDelete != null
            ? IconButton(
                icon: const Icon(Icons.delete_outline),
                color: theme.colorScheme.error,
                onPressed: onDelete,
                tooltip: 'Delete zone',
              )
            : const Icon(Icons.chevron_right),
      ),
    );
  }
}
