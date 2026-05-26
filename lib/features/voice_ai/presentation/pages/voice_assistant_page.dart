import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../bloc/voice_provider.dart';

class VoiceAssistantPage extends ConsumerStatefulWidget {
  const VoiceAssistantPage({super.key});

  @override
  ConsumerState<VoiceAssistantPage> createState() => _VoiceAssistantPageState();
}

class _VoiceAssistantPageState extends ConsumerState<VoiceAssistantPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final _openAiKeyController = TextEditingController();
  final _picoKeyController = TextEditingController();
  bool _obscureOpenAi = true;
  bool _obscurePico = true;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _openAiKeyController.dispose();
    _picoKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final voiceAsync = ref.watch(voiceNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hey Guardian'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: voiceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorBody(message: e.toString()),
        data: (state) => switch (state) {
          VoiceSetupRequired() => _SetupBody(
              openAiController: _openAiKeyController,
              picoController: _picoKeyController,
              obscureOpenAi: _obscureOpenAi,
              obscurePico: _obscurePico,
              onToggleOpenAi: () =>
                  setState(() => _obscureOpenAi = !_obscureOpenAi),
              onTogglePico: () =>
                  setState(() => _obscurePico = !_obscurePico),
              onSave: _saveKeys,
            ),
          VoiceIdle() => _IdleBody(
              pulseAnimation: _pulseAnimation,
              onMicTap: () =>
                  ref.read(voiceNotifierProvider.notifier).startListening(),
            ),
          VoiceListeningWakeWord() => _WakeWordBody(
              pulseAnimation: _pulseAnimation,
              onMicTap: () =>
                  ref.read(voiceNotifierProvider.notifier).startListening(),
            ),
          VoiceCapturingQuery() => _CapturingBody(pulseAnimation: _pulseAnimation),
          VoiceProcessing(:final transcript) => _ProcessingBody(transcript: transcript),
          VoiceResponding(:final transcript, :final response) =>
            _RespondingBody(transcript: transcript, response: response),
          VoiceError(:final message) => _ErrorBody(message: message),
        },
      ),
    );
  }

  Future<void> _saveKeys() async {
    final notifier = ref.read(voiceNotifierProvider.notifier);
    final openAiKey = _openAiKeyController.text.trim();
    final picoKey = _picoKeyController.text.trim();
    if (openAiKey.isEmpty) return;
    await notifier.saveOpenAIKey(openAiKey);
    if (picoKey.isNotEmpty) await notifier.savePicovoiceKey(picoKey);
  }
}

// ── Setup screen ──────────────────────────────────────────────────────────────

class _SetupBody extends StatelessWidget {
  const _SetupBody({
    required this.openAiController,
    required this.picoController,
    required this.obscureOpenAi,
    required this.obscurePico,
    required this.onToggleOpenAi,
    required this.onTogglePico,
    required this.onSave,
  });

  final TextEditingController openAiController;
  final TextEditingController picoController;
  final bool obscureOpenAi;
  final bool obscurePico;
  final VoidCallback onToggleOpenAi;
  final VoidCallback onTogglePico;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.xl),
          const Icon(Icons.mic_off_rounded, size: 72, color: AppColors.textSecondary),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Set up Hey Guardian',
            style: AppTypography.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Add your OpenAI API key to enable voice AI responses.',
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('OpenAI API Key *', style: AppTypography.label),
          const SizedBox(height: AppSpacing.xs),
          TextFormField(
            controller: openAiController,
            obscureText: obscureOpenAi,
            decoration: InputDecoration(
              hintText: 'sk-...',
              suffixIcon: IconButton(
                icon: Icon(obscureOpenAi ? Icons.visibility_off : Icons.visibility),
                onPressed: onToggleOpenAi,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Picovoice Access Key (optional — for wake word)', style: AppTypography.label),
          const SizedBox(height: AppSpacing.xs),
          TextFormField(
            controller: picoController,
            obscureText: obscurePico,
            decoration: InputDecoration(
              hintText: 'Paste your AccessKey from console.picovoice.ai',
              suffixIcon: IconButton(
                icon: Icon(obscurePico ? Icons.visibility_off : Icons.visibility),
                onPressed: onTogglePico,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Without this, use the mic button to start a query manually.',
            style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(
            onPressed: onSave,
            child: const Text('Save & start'),
          ),
        ],
      ),
    );
  }
}

// ── Idle / manual mic ─────────────────────────────────────────────────────────

class _IdleBody extends StatelessWidget {
  const _IdleBody({required this.pulseAnimation, required this.onMicTap});

  final Animation<double> pulseAnimation;
  final VoidCallback onMicTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _MicButton(
            pulseAnimation: pulseAnimation,
            color: AppColors.primary,
            icon: Icons.mic_rounded,
            onTap: onMicTap,
            animate: false,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Tap to speak',
            style: AppTypography.titleMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Or say "Hey Guardian" if wake word is configured',
            style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Wake word listening ───────────────────────────────────────────────────────

class _WakeWordBody extends StatelessWidget {
  const _WakeWordBody({required this.pulseAnimation, required this.onMicTap});

  final Animation<double> pulseAnimation;
  final VoidCallback onMicTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _MicButton(
            pulseAnimation: pulseAnimation,
            color: AppColors.safeGreen,
            icon: Icons.hearing_rounded,
            onTap: onMicTap,
            animate: true,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Listening for "Hey Guardian"', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Or tap the mic to ask something now',
            style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ── Capturing query ───────────────────────────────────────────────────────────

class _CapturingBody extends StatelessWidget {
  const _CapturingBody({required this.pulseAnimation});

  final Animation<double> pulseAnimation;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _MicButton(
            pulseAnimation: pulseAnimation,
            color: AppColors.warningAmber,
            icon: Icons.mic_rounded,
            onTap: null,
            animate: true,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Listening...', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Speak your question now',
            style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ── Processing ────────────────────────────────────────────────────────────────

class _ProcessingBody extends StatelessWidget {
  const _ProcessingBody({required this.transcript});

  final String transcript;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppSpacing.xl),
          Text('Thinking...', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('You said:', style: AppTypography.label),
                const SizedBox(height: AppSpacing.xs),
                Text(transcript, style: AppTypography.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Responding ────────────────────────────────────────────────────────────────

class _RespondingBody extends StatelessWidget {
  const _RespondingBody({required this.transcript, required this.response});

  final String transcript;
  final String response;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.xl),
          const Icon(Icons.volume_up_rounded, size: 48, color: AppColors.primary),
          const SizedBox(height: AppSpacing.lg),
          Text('Hey Guardian says:', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Text(response, style: AppTypography.bodyLarge),
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your question:', style: AppTypography.label),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  transcript,
                  style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error ─────────────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 64, color: AppColors.emergencyRed),
          const SizedBox(height: AppSpacing.lg),
          Text('Something went wrong', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Mic button ────────────────────────────────────────────────────────────────

class _MicButton extends StatelessWidget {
  const _MicButton({
    required this.pulseAnimation,
    required this.color,
    required this.icon,
    required this.onTap,
    required this.animate,
  });

  final Animation<double> pulseAnimation;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    Widget button = GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 24,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Icon(icon, size: 56, color: Colors.white),
      ),
    );

    if (!animate) return button;

    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (_, child) => Transform.scale(
        scale: pulseAnimation.value,
        child: child,
      ),
      child: button,
    );
  }
}
