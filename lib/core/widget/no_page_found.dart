import 'dart:math' as math;
import 'package:flutter/material.dart';

class NoPageFound extends StatefulWidget {
  const NoPageFound({
    super.key,
    this.onGoHome,
    this.onRetry,
    this.title = "Page not found",
    this.subtitle =
    "The page you’re looking for doesn’t exist, was moved, or the URL is incorrect.",
    this.homeLabel = "Go Home",
    this.retryLabel = "Try Again",
  });

  final VoidCallback? onGoHome;
  final VoidCallback? onRetry;
  final String title;
  final String subtitle;
  final String homeLabel;
  final String retryLabel;

  @override
  State<NoPageFound> createState() => _NoPageFoundState();
}

class _NoPageFoundState extends State<NoPageFound>
    with TickerProviderStateMixin {
  late final AnimationController _floatCtrl;
  late final Animation<double> _float;

  late final AnimationController _shineCtrl;
  late final Animation<double> _shine;

  @override
  void initState() {
    super.initState();

    // Gentle bobbing for the car icon
    _floatCtrl =
    AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
    _float = Tween<double>(begin: -6, end: 6)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_floatCtrl);

    // Slow "shine" sweep across 404 text
    _shineCtrl =
    AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat();
    _shine = Tween<double>(begin: 0, end: 1).animate(_shineCtrl);
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _shineCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 600;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? [
            theme.colorScheme.surfaceContainerHighest,
            theme.colorScheme.surface,
          ]
              : [
            theme.colorScheme.surface,
            theme.colorScheme.surfaceContainerHighest,
          ],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: LayoutBuilder(
                builder: (context, c) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTopArt(theme, isWide),
                      const SizedBox(height: 24),
                      _buildTexts(theme, isWide),
                      const SizedBox(height: 28),
                      _buildActions(context, theme, isWide),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopArt(ThemeData theme, bool isWide) {
    final textColor = theme.colorScheme.onSurface.withValues(alpha: 0.12);

    return SizedBox(
      height: isWide ? 220 : 180,
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _shine,
              builder: (context, _) {
                return ShaderMask(
                  shaderCallback: (Rect bounds) {
                    final w = bounds.width;
                    final x = _shine.value * (w + w * 0.4) - w * 0.2;
                    return LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withValues(alpha: 0.28),
                        Colors.transparent,
                      ],
                      stops: const [0.35, 0.5, 0.65],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      transform: GradientRotation(math.pi / 12),
                    ).createShader(Rect.fromLTWH(x - w, 0, w * 2, bounds.height));
                  },
                  blendMode: BlendMode.srcATop,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                      "404",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -2,
                        fontSize: isWide ? 220 : 180,
                        color: textColor,
                        height: 1.0,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Floating car icon
          Align(
            alignment: Alignment.center,
            child: AnimatedBuilder(
              animation: _float,
              builder: (context, _) {
                return Transform.translate(
                  offset: Offset(0, _float.value),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.18),
                          blurRadius: 22,
                          spreadRadius: 2,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.directions_car_filled_rounded,
                      size: isWide ? 54 : 44,
                      color: theme.colorScheme.onPrimaryContainer,
                      semanticLabel: "Car icon",
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTexts(ThemeData theme, bool isWide) {
    final onSurface = theme.colorScheme.onSurface;

    return Column(
      children: [
        Text(
          widget.title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          widget.subtitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: onSurface.withValues(alpha: 0.72),
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, ThemeData theme, bool isWide) {
    final onSurface = theme.colorScheme.onSurface;
    final spacing = isWide ? 14.0 : 10.0;

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      alignment: WrapAlignment.center,
      children: [
        // Primary CTA
        ElevatedButton.icon(
          onPressed: widget.onGoHome,
          icon: const Icon(Icons.home_rounded),
          label: Text(widget.homeLabel),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        // Secondary CTA
        OutlinedButton.icon(
          onPressed: widget.onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: Text(widget.retryLabel),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            side: BorderSide(color: onSurface.withValues(alpha: 0.18)),
          ),
        ),
      ],
    );
  }
}