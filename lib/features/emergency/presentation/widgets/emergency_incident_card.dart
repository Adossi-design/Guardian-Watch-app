import 'package:flutter/material.dart';
import '../../domain/entities/emergency_incident.dart';

class EmergencyIncidentCard extends StatelessWidget {
  const EmergencyIncidentCard({
    super.key,
    required this.incident,
    this.onAcknowledge,
  });

  final EmergencyIncident incident;
  final VoidCallback? onAcknowledge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCountdown = incident.status == EmergencyStatus.countdown;

    return Card(
      color: isCountdown ? Colors.orange.shade50 : Colors.red.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCountdown ? Colors.orange.shade400 : Colors.red.shade400,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isCountdown ? Icons.timer_outlined : Icons.warning_rounded,
                  color: isCountdown ? Colors.orange.shade700 : Colors.red.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    incident.userName ?? 'Unknown User',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isCountdown
                          ? Colors.orange.shade900
                          : Colors.red.shade900,
                    ),
                  ),
                ),
                _StatusChip(status: incident.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              incident.triggerType.displayName,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              _formatTime(incident.startedAt),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (onAcknowledge != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onAcknowledge,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                    side: BorderSide(color: Colors.red.shade400),
                  ),
                  child: const Text('Acknowledge'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} h ago';
    return '${dt.month}/${dt.day} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final EmergencyStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      EmergencyStatus.countdown => ('Countdown', Colors.orange),
      EmergencyStatus.active => ('Active', Colors.red),
      EmergencyStatus.resolved => ('Resolved', Colors.green),
      EmergencyStatus.cancelled => ('Cancelled', Colors.grey),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color.shade800,
        ),
      ),
    );
  }
}
