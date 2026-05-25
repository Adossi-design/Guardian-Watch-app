import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../design_system/widgets/guardian_button.dart';
import '../../../auth/presentation/bloc/auth_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (user != null) ...[
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(user.name),
                  subtitle: Text(user.email),
                ),
                const Divider(),
              ],
              const SizedBox(height: AppSpacing.xl),
              GuardianButton(
                label: 'Sign out',
                variant: GuardianButtonVariant.danger,
                onPressed: () => ref.read(authNotifierProvider.notifier).signOut(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
