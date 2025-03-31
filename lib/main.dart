import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/home_page.dart';
import 'pages/landing_page.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green, brightness: Brightness.dark),
        fontFamily: GoogleFonts.oxanium().fontFamily,
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
      home: const AppInitializer(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool? _isFirstTime;

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    String? value = await _storage.read(key: "isFirstTime");

    if (value == null) {
      await _storage.write(key: "isFirstTime", value: "true");
      setState(() => _isFirstTime = true);
    } else {
      setState(() => _isFirstTime = value == "true");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isFirstTime == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return _isFirstTime! ? const LandingPage() : const HomePage();
  }
}
