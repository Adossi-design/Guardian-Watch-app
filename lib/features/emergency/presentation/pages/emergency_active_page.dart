import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../bloc/emergency_provider.dart';

class EmergencyActivePage extends ConsumerWidget {
  const EmergencyActivePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(emergencyNotifierProvider).valueOrNull;

    if (state is! EmergencyActiveState) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/dashboard/primary');
      });
      return const SizedBox.shrink();
    }

    final incident = state.incident;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFCC0000),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.warning_rounded, color: Colors.white, size: 80),
              const SizedBox(height: 24),
              Text(
                'EMERGENCY ACTIVE',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                incident.triggerType.displayName,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Monitors are being notified.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFCC0000),
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  await ref
                      .read(emergencyNotifierProvider.notifier)
                      .resolveEmergency();
                  if (context.mounted) context.go('/dashboard/primary');
                },
                child: const Text(
                  'I AM SAFE — RESOLVE EMERGENCY',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
