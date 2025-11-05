import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

// Screens
import 'screens/authentication/authscreen.dart';
import 'screens/main_navigation_screen.dart';

/// 🎨 Global Unified Color Scheme
const kPrimaryColor = Color(0xFF6C63FF); // Vibrant purple-blue
const kAccentColor = Color(0xFF836FFF);  // Soft gradient accent
const kBackgroundLight = Color(0xFFF7F4FF); // Light background
const kBackgroundDark = Color(0xFF1B1B2F);  // Dark background
const kCardLight = Color(0xFFF0EFFF); // Light card color
const kCardDark = Color(0xFF2E2E42); // Dark card color
const kTextPrimaryLight = Color(0xFF1E1E2E);
const kTextPrimaryDark = Color(0xFFEAEAF6);
const kTextSecondary = Color(0xFF8E8E99);
const kSuccessColor = Color(0xFF4CAF50);
const kErrorColor = Color(0xFFE53935);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense & Fitness Tracker',
      debugShowCheckedModeBanner: false,

      /// 🌞 LIGHT THEME
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: kBackgroundLight,
        appBarTheme: const AppBarTheme(
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
    color: kCardLight,
    elevation: 3,
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: kTextPrimaryLight, fontSize: 16),
          bodyMedium: TextStyle(color: kTextSecondary, fontSize: 14),
          titleLarge: TextStyle(
            fontWeight: FontWeight.bold,
            color: kTextPrimaryLight,
            fontSize: 18,
          ),
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryColor).copyWith(
          secondary: kAccentColor,
        ),
      ),

      /// 🌙 DARK THEME
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: kBackgroundDark,
        appBarTheme: const AppBarTheme(
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
    color: kCardDark,
    elevation: 3,
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: kTextPrimaryDark, fontSize: 16),
          bodyMedium: TextStyle(color: Colors.grey, fontSize: 14),
          titleLarge: TextStyle(
            fontWeight: FontWeight.bold,
            color: kTextPrimaryDark,
            fontSize: 18,
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: kPrimaryColor,
        ).copyWith(secondary: kAccentColor),
      ),

      /// 🌓 Use system setting (auto-switch)
      themeMode: ThemeMode.system,

      /// 🔥 Firebase Auth Navigation
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const MainNavigationScreen();
          }
          return const AuthScreen();
        },
      ),
    );
  }
}
