import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../design_system/widgets/guardian_button.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingData(
      icon: Icons.shield_rounded,
      title: 'Always Protected',
      body: 'GuardianWatch monitors your health 24/7 and alerts your loved ones the moment something needs attention.',
      color: AppColors.primary,
    ),
    _OnboardingData(
      icon: Icons.favorite_rounded,
      title: 'Connected Family',
      body: 'Unlimited caregivers receive every alert simultaneously in real time — no one misses a thing.',
      color: AppColors.emergencyRed,
    ),
    _OnboardingData(
      icon: Icons.mic_rounded,
      title: 'Hey Guardian',
      body: 'Ask "Hey Guardian, how is grandma doing?" and get a real answer from live health data — hands-free.',
      color: AppColors.safeGreen,
    ),
    _OnboardingData(
      icon: Icons.location_on_rounded,
      title: 'Safe Zones',
      body: 'Draw safe zones on the map. Get instant alerts the moment your loved one steps outside.',
      color: AppColors.warningAmber,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (context, index) => _OnboardingSlide(data: _pages[index]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _controller,
                    count: _pages.length,
                    effect: const ExpandingDotsEffect(
                      activeDotColor: AppColors.primary,
                      dotColor: AppColors.borderLight,
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (_currentPage < _pages.length - 1) ...[
                    GuardianButton(
                      label: 'Next',
                      onPressed: () => _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    GuardianButton(
                      label: 'Skip',
                      onPressed: () => context.go('/sign-in'),
                      variant: GuardianButtonVariant.text,
                    ),
                  ] else ...[
                    GuardianButton(
                      label: 'Get started',
                      onPressed: () => context.go('/register'),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    GuardianButton(
                      label: 'I already have an account',
                      onPressed: () => context.go('/sign-in'),
                      variant: GuardianButtonVariant.outlined,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingData {
  const _OnboardingData({
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color color;
}

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({required this.data});
  final _OnboardingData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, color: data.color, size: 56),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            data.title,
            style: AppTypography.headline,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            data.body,
            style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
