class AppConstants {
  // App Info
  static const String appName = 'Tejas';
  static const String appTagline = 'The only live\nOn-demand tutoring\nservice in the world';
  
  // API Configuration
  static const String baseUrl = 'http://localhost:3000'; // Update this to your actual backend URL
  static const Duration requestTimeout = Duration(seconds: 30);
  
  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String onboardingCompleteKey = 'onboarding_complete';
  
  // Validation
  static const int otpLength = 6;
  static const int otpTimeoutSeconds = 60;
  static const int maxNameLength = 50;
  static const int minNameLength = 2;
  
  // UI Constants
  static const double defaultPadding = 24.0;
  static const double defaultBorderRadius = 12.0;
  static const double buttonHeight = 56.0;
  static const double buttonBorderRadius = 28.0;
}
