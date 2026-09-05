import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_components.dart';
import '../../../main.dart';
import '../auth/sign_in.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _controller.forward();

    Future.delayed(const Duration(milliseconds: 1800), () async {
      if (mounted) {
        final hasSeenOnboarding = await storageService.isOnboardingSeen();
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => hasSeenOnboarding
                ? const SignInScreen()
                : const OnboardingScreen(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            const Positioned.fill(
              child: CustomPaint(painter: _SplashPitchPainter()),
            ),
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) => Transform.scale(
                        scale: _scaleAnimation.value,
                        child: FadeTransition(
                          opacity: _controller,
                          child: child,
                        ),
                      ),
                      child: const BrandLogoTile(size: 96),
                    ),
                    const SizedBox(height: 26),
                    Text(
                      'Créneau Médéa',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            color: AppColors.primary,
                            letterSpacing: -.4,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'رتّب لعبتك، واجمع فريقك',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 36),
                    SizedBox(
                      width: 110,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: const LinearProgressIndicator(
                          minHeight: 4,
                          value: .76,
                          backgroundColor: AppColors.primaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            PositionedDirectional(
              start: 0,
              end: 0,
              bottom: 26,
              child: SafeArea(
                top: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'مباريات مجتمع Médéa',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashPitchPainter extends CustomPainter {
  const _SplashPitchPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withAlpha(13)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final field = Rect.fromLTWH(
      size.width * .08,
      size.height * .08,
      size.width * .84,
      size.height * .84,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(field, const Radius.circular(26)),
      paint,
    );
    canvas.drawLine(
      Offset(field.left, field.center.dy),
      Offset(field.right, field.center.dy),
      paint,
    );
    canvas.drawCircle(field.center, size.width * .13, paint);
    canvas.drawCircle(
      field.center,
      3,
      Paint()..color = AppColors.primary.withAlpha(28),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
