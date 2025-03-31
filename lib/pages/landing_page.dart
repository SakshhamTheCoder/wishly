import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wishly/components/default_scaffold.dart';
import 'home_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<Offset> _slide2Animation;
  late Animation<double> _fadeAnimation;
  double _turns = 0;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _isRotating = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0), // Start off-screen
      end: Offset.zero, // End at the original position
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.fastEaseInToSlowEaseOut),
    );
    _slide2Animation = Tween<Offset>(
      begin: const Offset(0.0, 5.0), // Start off-screen
      end: Offset.zero, // End at the original position
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.fastEaseInToSlowEaseOut),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0, // Start with 0 opacity
      end: 1.0, // End with full opacity
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
    _startInfiniteRotation();
  }

  void _startInfiniteRotation() async {
    while (_isRotating && mounted) {
      await Future.delayed(const Duration(milliseconds: 100));
      setState(() {
        _turns += 1.0 / 60.0;
      });
    }
  }

  void _onGetStarted() async {
    await _storage.write(key: "isFirstTime", value: "false");
    setState(() => _isRotating = false); // Stop rotation
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _isRotating = false; // Stop rotation when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DefaultScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SlideTransition(
            position: _slideAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                Text("This is", style: TextStyle(fontSize: 32)),
                Text(
                  "WISHLY",
                  style: TextStyle(
                    fontSize: 64,
                    height: 0.8,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Never forget wishing your loved ones",
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
          FadeTransition(
            opacity: _fadeAnimation,
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer.withAlpha(100),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: AnimatedRotation(
                    duration: const Duration(milliseconds: 100),
                    turns: _turns,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: SvgPicture.asset(
                        "assets/flower-svgrepo-com.svg",
                        colorFilter: ColorFilter.mode(
                          colorScheme.onSecondaryContainer.withAlpha(40),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SlideTransition(
            position: _slide2Animation,
            child: SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: _onGetStarted,
                child: const Text("Get Started", style: TextStyle(fontSize: 18)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
