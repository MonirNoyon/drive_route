import 'dart:async';
import 'dart:ui';
import 'package:car_routing_application/core/widget/no_page_found.dart';
import 'package:car_routing_application/features/home/presentation/home.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _dashController;   // animates the dashed route
  late final AnimationController _fadeController;   // fades in brand + CTA

  @override
  void initState() {
    super.initState();

    _dashController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(); // continuous dash offset animation

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    // Simulate init work, then navigate
    Future.delayed(const Duration(milliseconds: 1500), () async {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 550),
          pageBuilder: (_, __, ___) => const HomePage(),
          transitionsBuilder: (_, anim, __, child) {
            final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.03),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _dashController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF0B1220), const Color(0xFF111A2D)]
                : [const Color(0xFFEFF3FF), const Color(0xFFE7EEFF)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Animated route background
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _dashController,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: RoutePainter(
                        dashPhase: _dashController.value,
                        routeColor: cs.primary.withOpacity(isDark ? 0.75 : 0.9),
                        waypointColor: cs.secondary,
                      ),
                    );
                  },
                ),
              ),

              // Foreground branding
              Align(
                alignment: Alignment.center,
                child: FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _fadeController,
                    curve: Curves.easeOut,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo mark
                      Container(
                        height: 92,
                        width: 92,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              cs.primary,
                              cs.primary.withOpacity(0.75),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 24,
                              spreadRadius: 2,
                              offset: const Offset(0, 10),
                              color: cs.primary.withOpacity(0.35),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.directions_car_filled_rounded,
                          size: 44,
                          color: cs.onPrimary,
                          semanticLabel: 'DriveRoute logo',
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'DriveRoute',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: isDark ? Colors.white : const Color(0xFF0E1A33),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Smart routing for fleets',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: isDark
                              ? Colors.white70
                              : const Color(0xFF2A3A5C).withOpacity(0.75),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Subtle progress indicator
                      SizedBox(
                        width: 120,
                        child: LinearProgressIndicator(
                          minHeight: 5,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Footer (version or tagline)
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '© ${DateTime.now().year} DriveRoute',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                    Text(
                      'v1.0.0',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A custom painter that draws a stylized "route" with animated dashed stroke,
/// plus origin/destination pins. No external packages needed.
class RoutePainter extends CustomPainter {
  RoutePainter({
    required this.dashPhase,
    required this.routeColor,
    required this.waypointColor,
  });

  /// 0..1, shifts the dash pattern to create motion
  final double dashPhase;
  final Color routeColor;
  final Color waypointColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..color = routeColor;

    // Create a nice bezier route path with gentle curves
    final path = Path();
    final start = Offset(size.width * 0.12, size.height * 0.70);
    final mid1  = Offset(size.width * 0.35, size.height * 0.45);
    final mid2  = Offset(size.width * 0.65, size.height * 0.80);
    final end   = Offset(size.width * 0.86, size.height * 0.30);

    path.moveTo(start.dx, start.dy);
    path.cubicTo(
      size.width * 0.20, size.height * 0.62,
      mid1.dx,            mid1.dy,
      size.width * 0.48,  size.height * 0.52,
    );
    path.cubicTo(
      mid2.dx,            mid2.dy,
      size.width * 0.78,  size.height * 0.45,
      end.dx,             end.dy,
    );

    // Draw dashed path with animated offset
    _drawDashedPath(canvas, path, paint, dashArray: const [12, 10], phase: dashPhase);

    // Draw origin/destination pins
    _drawPin(canvas, start, waypointColor, fill: true);
    _drawPin(canvas, end, routeColor, fill: false);

    // Moving "car" dot traveling along the path
    final metrics = path.computeMetrics().toList();
    if (metrics.isNotEmpty) {
      final m = metrics.first;
      final t = (dashPhase % 1.0);
      final pos = m.getTangentForOffset(m.length * t)!.position;
      final carPaint = Paint()..color = routeColor.withOpacity(0.95);
      canvas.drawCircle(pos, 6, carPaint);
      canvas.drawCircle(pos, 9, carPaint..color = routeColor.withOpacity(0.12));
    }
  }

  void _drawDashedPath(
      Canvas canvas,
      Path path,
      Paint paint, {
        required List<double> dashArray,
        required double phase,
      }) {
    final dashPath = Path();
    for (final metric in path.computeMetrics()) {
      double distance = (dashArray.fold<double>(0, (a, b) => a + b) * phase);
      while (distance < metric.length) {
        final double len = dashArray[0];
        final double gap = dashArray[1];
        final double next = math.min(distance + len, metric.length);
        dashPath.addPath(metric.extractPath(distance, next), Offset.zero);
        distance = next + gap;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  void _drawPin(Canvas canvas, Offset c, Color color, {required bool fill}) {
    final pinPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = fill ? color : Colors.transparent;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = color;

    final path = Path();
    path.moveTo(c.dx, c.dy - 14);
    path.quadraticBezierTo(c.dx + 12, c.dy - 14, c.dx + 12, c.dy);
    path.quadraticBezierTo(c.dx + 12, c.dy + 14, c.dx, c.dy + 24);
    path.quadraticBezierTo(c.dx - 12, c.dy + 14, c.dx - 12, c.dy);
    path.quadraticBezierTo(c.dx - 12, c.dy - 14, c.dx, c.dy - 14);
    path.close();

    canvas.drawPath(path, pinPaint);
    canvas.drawPath(path, stroke);

    // inner circle
    canvas.drawCircle(c, 4.5, Paint()..color = Colors.white.withOpacity(0.9));
  }

  @override
  bool shouldRepaint(covariant RoutePainter oldDelegate) {
    return oldDelegate.dashPhase != dashPhase ||
        oldDelegate.routeColor != routeColor ||
        oldDelegate.waypointColor != waypointColor;
  }
}
