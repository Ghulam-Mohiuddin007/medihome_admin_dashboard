import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medihome_admin_dashboard/admin_dashboard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final _supabase = Supabase.instance.client;

  // اینیمیشن کنٹرولرز
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  // پریمیم کلر پیلیٹ (Metallic ডार्क Luxe Theme)
  final Color bgDark = const Color(0xFF020617);
  final Color surfaceSlate = const Color(0xFF0F172A);
  final Color electricTeal = const Color(0xFF00D2FF);
  final Color brandBlue = const Color(0xFF1E90FF);

  @override
  void initState() {
    super.initState();

    // एनیمیشن سیٹ اپ (800ms کا پریمیم مائیکرو انٹرایکشن لوپ)
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _rotateAnimation = Tween<double>(begin: 0.25, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
      ),
    );

    // اینیمیشن شروع کریں
    _animationController.forward();

    // 3 سیکنڈ کے پریمیم ہینڈ شیک کے بعد لاگ ان اسکرین پر نیویگیشن
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // لوپس بیک گراؤنڈ آرٹ (Glassmorphic Ambient Background Orbs)
          Positioned(
            top: -100,
            left: -100,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: electricTeal.withValues(alpha: 0.03),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            right: -50,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: brandBlue.withValues(alpha: 0.03),
              ),
            ),
          ),

          // مین برانڈنگ اینیمیشن بلاک (Animated Center Content Block)
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Transform.rotate(
                    angle: _rotateAnimation.value * 3.14159,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // گلوزنگ میٹیلک برانڈ ہوم لوگو (Glowing Brand Metallic Icon Core)
                        Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [electricTeal, brandBlue],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: electricTeal.withValues(alpha: 0.3),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.health_and_safety_rounded,
                            color: Colors.white,
                            size: 65,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // برانڈ ٹیکسٹ (Luxe Montserrat Typography)
                        Text(
                          "MediHome",
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 6),

                        Text(
                          "Healthcare Delivered At Doorstep",
                          style: GoogleFonts.inter(
                            color: const Color(0xFF64748B),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // ریموٹ بوٹم لوڈر انٹرایکشن (Sleek Minimal Progress Indicator)
          Positioned(
            bottom: 60,
            child: Opacity(
              opacity: 0.8,
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  color: electricTeal,
                  strokeWidth: 2.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
