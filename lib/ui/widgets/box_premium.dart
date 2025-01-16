import 'package:flutter/cupertino.dart';
import 'package:scan_doc/ui/resurses/colors.dart';
import 'package:scan_doc/ui/screens/main/widgets/folders_list.dart';
import 'dart:math' as math;

class BoxPremium extends StatefulWidget {
  final Widget child;
  final double height;
  final double width;
  final bool widthInfinity;
  final int countDots;
  final int radiusDots;
  final Color color;

  const BoxPremium({
    super.key,
    required this.child,
    this.height = 50,
    this.widthInfinity = true,
    this.width = double.infinity,
    this.color = AppColors.primary,
    this.countDots = 50,
    this.radiusDots = 100,
  });

  @override
  State<BoxPremium> createState() => _BoxPremiumState();
}

class _BoxPremiumState extends State<BoxPremium> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _rotationController;
  late AnimationController _bounceController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  final List<ParticleModel> _particles = [];
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateParticles();
  }

  void _initializeAnimations() {
    _mainController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.1), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.2, end: 0.6), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.6, end: 0.2), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeInOut,
    ));
  }

  void _generateParticles() {
    for (int i = 0; i < widget.countDots; i++) {
      _particles.add(ParticleModel(
        angle: _random.nextDouble() * 2 * math.pi,
        radius: _random.nextDouble() * widget.radiusDots + 20,
        speed: _random.nextDouble() * 0.5 + 0.5,
      ));
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _rotationController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.color;

    return SizedBox(
      width: widget.widthInfinity ? double.infinity : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Particles
          ...List.generate(_particles.length, (index) {
            return AnimatedBuilder(
              animation: _mainController,
              builder: (context, child) {
                final particle = _particles[index];
                final offset = Offset(
                  math.cos(particle.angle) * particle.radius * _scaleAnimation.value + 20,
                  math.sin(particle.angle) * particle.radius * _scaleAnimation.value,
                );

                return Transform.translate(
                  offset: offset,
                  child: Opacity(
                    opacity: _glowAnimation.value * 0.5,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.textPrimary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.5),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // Glow
          AnimatedBuilder(
            animation: _mainController,
            builder: (context, child) {
              return Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(_glowAnimation.value),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              );
            },
          ),
          widget.child,
          if (false)
            Container(
              width: 60,
              height: 40,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: primaryColor.withOpacity(0.3),
                ),
              ),
              child: Icon(
                CupertinoIcons.folder_fill,
                color: primaryColor,
                size: 30,
              ),
            ),
        ],
      ),
    );
  }
}
