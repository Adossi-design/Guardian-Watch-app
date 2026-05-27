import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../auth/presentation/bloc/auth_provider.dart';
import '../bloc/invite_provider.dart';

class AcceptInvitePage extends ConsumerStatefulWidget {
  const AcceptInvitePage({super.key});

  @override
  ConsumerState<AcceptInvitePage> createState() => _AcceptInvitePageState();
}

class _AcceptInvitePageState extends ConsumerState<AcceptInvitePage> {
  final _scannerController = MobileScannerController();
  final _codeController = TextEditingController();
  bool _scanned = false;

  @override
  void dispose() {
    _scannerController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<InviteState>>(inviteNotifierProvider, (_, next) {
      final s = next.valueOrNull;
      if (s is InviteAccepted) {
        // Reload user so updated household_id is reflected in all providers
        ref.invalidate(authNotifierProvider);
        context.go('/dashboard/monitor');
      }
    });

    final inviteAsync = ref.watch(inviteNotifierProvider);
    final isLoading = inviteAsync.valueOrNull is InviteLoading;
    final error = inviteAsync.valueOrNull is InviteError
        ? (inviteAsync.valueOrNull as InviteError).message
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Join a household'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // QR scanner viewport
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  MobileScanner(
                    controller: _scannerController,
                    onDetect: _onDetect,
                  ),
                  // Overlay hint
                  Positioned(
                    bottom: AppSpacing.lg,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        child: Text(
                          'Point at the QR code on the primary user\'s phone',
                          style: AppTypography.label.copyWith(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Manual entry + status
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Or paste the invite link manually:',
                      style: AppTypography.label.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _codeController,
                            decoration: const InputDecoration(
                              hintText: 'guardianwatch://invite/...',
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        FilledButton(
                          onPressed: isLoading ? null : _submitManual,
                          child: const Text('Join'),
                        ),
                      ],
                    ),
                    if (error != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.emergencyRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        child: Text(
                          error,
                          style: AppTypography.body.copyWith(color: AppColors.emergencyRed),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextButton(
                        onPressed: _retry,
                        child: const Text('Try again'),
                      ),
                    ],
                    if (isLoading) ...[
                      const SizedBox(height: AppSpacing.lg),
                      const Center(child: CircularProgressIndicator()),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Connecting to household...',
                        style: AppTypography.label.copyWith(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code == null) return;
    setState(() => _scanned = true);
    _scannerController.stop();
    final inviteId = _parseInviteId(code);
    if (inviteId != null) {
      _codeController.text = code;
      _accept(inviteId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR code does not contain a valid invite.')),
      );
      setState(() => _scanned = false);
      _scannerController.start();
    }
  }

  void _submitManual() {
    final raw = _codeController.text.trim();
    if (raw.isEmpty) return;
    final id = _parseInviteId(raw) ?? raw;
    _accept(id);
  }

  Future<void> _accept(String inviteId) async {
    final name = ref.read(currentUserProvider)?.name ?? 'Monitor';
    await ref.read(inviteNotifierProvider.notifier).acceptInvite(inviteId, name);
  }

  void _retry() {
    setState(() => _scanned = false);
    _scannerController.start();
    ref.read(inviteNotifierProvider.notifier).reset();
  }

  static String? _parseInviteId(String raw) {
    // guardianwatch://invite/{id}
    if (raw.startsWith('guardianwatch://invite/')) {
      final id = raw.substring('guardianwatch://invite/'.length);
      return id.isNotEmpty ? id : null;
    }
    final uri = Uri.tryParse(raw);
    if (uri != null && uri.scheme == 'guardianwatch' && uri.host == 'invite') {
      return uri.pathSegments.firstOrNull;
    }
    // Bare UUID
    if (raw.length >= 32 && raw.contains('-')) return raw;
    return null;
  }
}
