import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../design_system/widgets/emergency_countdown.dart';
import '../bloc/emergency_provider.dart';

// Full-screen countdown page. Navigated to automatically by the primary
// dashboard when EmergencyCountdownState is emitted.
class EmergencyCountdownPage extends ConsumerWidget {
  const EmergencyCountdownPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(emergencyNotifierProvider).valueOrNull;

    if (state is! EmergencyCountdownState) {
      // State changed while page was open (e.g. already activated)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/dashboard/primary');
      });
      return const SizedBox.shrink();
    }

    return EmergencyCountdown(
      seconds: state.secondsRemaining,
      message: _message(state.incident.triggerType.displayName),
      onCountdownComplete: () =>
          ref.read(emergencyNotifierProvider.notifier).activateNow(state.incident),
      onCancelled: () async {
        await ref.read(emergencyNotifierProvider.notifier).cancelCountdown();
        if (context.mounted) context.go('/dashboard/primary');
      },
    );
  }

  static String _message(String triggerType) =>
      'EMERGENCY ALERT\n$triggerType\n\nNotifying your monitors in...';
}
