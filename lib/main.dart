import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/onboarding/language_selection_screen.dart';
import 'screens/tutor_onboarding/tutor_language_selection_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/onboarding_provider.dart';
import 'providers/tutor_onboarding_provider.dart';
import 'providers/questions_provider.dart';
import 'providers/chat_provider.dart';
import 'services/storage_service.dart';
import 'services/api_service.dart';
import 'services/global_chat_service.dart';
import 'services/app_lifecycle_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await StorageService.initialize();
  ApiService().initialize();

  // Initialize app lifecycle service
  AppLifecycleService().initialize();

  runApp(const TejasApp());
}

class TejasApp extends StatelessWidget {
  const TejasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(create: (_) => TutorOnboardingProvider()),
        ChangeNotifierProvider(create: (_) => QuestionsProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => GlobalChatService()),
      ],
      child: MaterialApp(
        title: 'Tejas - Online Tutoring',
        theme: AppTheme.lightTheme,
        home: const AppInitializer(),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/splash': (context) => const SplashScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.initializeFromStorage();
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Check if user is logged in and onboarding is complete
        final isLoggedIn = StorageService.isLoggedIn() || authProvider.isLoggedIn;
        final isOnboardingComplete = StorageService.isOnboardingComplete();

        // If user is logged in and has a role, go to dashboard
        if (isLoggedIn && authProvider.userRole != null) {
          return const HomeScreen();
        }

        if (isLoggedIn && isOnboardingComplete) {
          // Navigate to main app (which will route to appropriate dashboard)
          return const HomeScreen();
        } else if (isLoggedIn && !isOnboardingComplete) {
          // User is logged in but hasn't completed onboarding
          // Navigate to appropriate onboarding flow based on role
          if (authProvider.userRole == UserRole.student) {
            return const LanguageSelectionScreen();
          } else if (authProvider.userRole == UserRole.tutor) {
            return const TutorLanguageSelectionScreen();
          } else {
            // Fallback to splash if role is not determined
            return const SplashScreen();
          }
        } else {
          // Show splash screen for authentication flow
          return const SplashScreen();
        }
      },
    );
  }
}
