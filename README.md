# Tejas - Online Tutoring Platform (Flutter App)

A comprehensive Flutter mobile application for the Tejas online tutoring platform that connects students with qualified tutors. Features complete authentication, real-time chat, question management, and tutor-student matching.

## 🚀 Features Implemented

### Authentication & User Management

- ✅ **Complete Auth Flow** - Registration, login, OTP verification
- ✅ **Role-based Access** - Student and Tutor dashboards
- ✅ **Profile Management** - Comprehensive user profiles
- ✅ **Onboarding** - Guided setup for both user types
- ✅ **JWT Authentication** - Secure token-based auth
- ✅ **Persistent Sessions** - Auto-login with stored credentials

### Core Platform Features

- ✅ **Question Management** - Create, view, and manage questions
- ✅ **Real-time Chat** - Instant messaging between students and tutors
- ✅ **Tutor Matching** - Browse and accept available questions
- ✅ **Global Chat Service** - Background message polling across all chats
- ✅ **Question Filtering** - Filter by subject, class level, etc.
- ✅ **Status Tracking** - Question lifecycle management

### Student Features

- ✅ **Post Questions** - Create questions with images and details
- ✅ **Track Progress** - Monitor question status and responses
- ✅ **Chat with Tutors** - Direct communication channel
- ✅ **Question History** - View all past questions

### Tutor Features

- ✅ **Browse Questions** - View available questions to answer
- ✅ **Accept Questions** - Take on student questions
- ✅ **Assignment Dashboard** - Manage accepted questions
- ✅ **Real-time Notifications** - Get notified of new messages
- ✅ **Profile Setup** - Detailed tutor qualifications and availability

### Technical Features

- ✅ **Clean Architecture** - Organized, maintainable code structure
- ✅ **State Management** - Provider pattern with proper separation
- ✅ **Real-time Updates** - Polling-based message updates
- ✅ **App Lifecycle Management** - Battery-efficient background handling
- ✅ **Error Handling** - Comprehensive error management
- ✅ **Loading States** - Smooth UX with proper loading indicators
- ✅ **Offline Handling** - Graceful degradation when offline

## 📱 Screens Overview

### Authentication Screens

1. **Splash Screen** - App branding and navigation to login/signup
2. **Login Screen** - Phone number input with country selection
3. **OTP Verification** - PIN code input with resend functionality
4. **Verification Success** - Success confirmation with animation
5. **Name & Gender** - Personal information collection
6. **Role Selection** - Student vs Educator choice

### Student Onboarding

1. **Language Selection** - Learning language preference
2. **Class Selection** - Academic level selection
3. **Stream Selection** - Academic stream for personalization

### Tutor Onboarding

1. **Language Selection** - Teaching language preference
2. **Education Details** - Qualifications and experience
3. **Teaching Preferences** - Subjects and class levels
4. **Availability Setup** - Days and time slots

### Main App Screens

1. **Student Dashboard** - Question management and chat access
2. **Tutor Dashboard** - Available questions and assignments
3. **Question Creation** - Post new questions with images
4. **Question Details** - View question information and status
5. **Chat Screen** - Real-time messaging interface
6. **Available Questions** - Browse questions (tutors)
7. **My Questions** - Student's question history
8. **My Assignments** - Tutor's accepted questions

## 🏗️ Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart      # App-wide constants
│   └── theme/
│       ├── app_colors.dart         # Color palette
│       └── app_theme.dart          # Theme configuration
├── models/
│   ├── message.dart                # Chat message model
│   ├── question.dart               # Question model
│   └── question_dto.dart           # Question data transfer objects
├── providers/
│   ├── auth_provider.dart          # Authentication state management
│   ├── onboarding_provider.dart    # Student onboarding state
│   ├── tutor_onboarding_provider.dart # Tutor onboarding state
│   ├── questions_provider.dart     # Question management state
│   └── chat_provider.dart          # Chat state management
├── screens/
│   ├── auth/                       # Authentication screens
│   ├── onboarding/                 # Student onboarding screens
│   ├── tutor_onboarding/           # Tutor onboarding screens
│   ├── student_onboarding/         # Student-specific onboarding
│   ├── dashboard/                  # Dashboard screens
│   ├── questions/                  # Question management screens
│   ├── chat/                       # Chat interface screens
│   └── home/                       # Home and navigation screens
├── services/
│   ├── api_service.dart            # HTTP API service with full endpoints
│   ├── storage_service.dart        # Local storage service
│   ├── global_chat_service.dart    # Global chat polling service
│   ├── notification_service.dart   # In-app notification service
│   └── app_lifecycle_service.dart  # App lifecycle management
├── utils/
│   └── validators.dart             # Form validation utilities
├── widgets/
│   ├── custom_button.dart          # Reusable button component
│   ├── custom_text_field.dart      # Custom text input widget
│   ├── loading_overlay.dart        # Loading overlay widget
│   ├── language_option.dart        # Language selection widget
│   ├── class_option.dart           # Class selection widget
│   └── unread_messages_badge.dart  # Unread message indicator
└── main.dart                       # App entry point with providers
```

## 🎨 Design System

### Colors

- **Primary**: #2563EB (Blue)
- **Background**: #FFFFFF (White)
- **Text Primary**: #0F172A (Dark)
- **Text Secondary**: #64748B (Gray)
- **Success**: #10B981 (Green)
- **Error**: #EF4444 (Red)

### Typography

- **Font Family**: SF Pro Display
- **Display**: 28px, Bold (Titles)
- **Body**: 16px, Regular (Content)
- **Caption**: 14px, Medium (Subtitles)

## 📦 Dependencies

### Core Dependencies

- `flutter`: SDK
- `provider`: State management for app-wide state
- `dio`: HTTP client for API communication
- `shared_preferences`: Local storage for user data
- `image_picker`: Camera and gallery image selection

### UI Dependencies

- `pin_code_fields`: OTP input fields
- `country_picker`: Country selection widget
- `flutter_svg`: SVG image support
- `cached_network_image`: Efficient image loading and caching

### Development Dependencies

- `flutter_lints`: Code linting and best practices
- `pretty_dio_logger`: API request/response logging

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.10.0)
- Dart SDK (>=3.0.0)
- Android Studio / VS Code
- Android/iOS device or emulator

### Installation

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd Tejas/body
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 🔧 Configuration

### API Configuration

Update the base URL in `lib/core/constants/app_constants.dart`:

```dart
static const String baseUrl = 'http://localhost:3000'; // Your NestJS backend URL
```

### Backend Integration

The app is **fully integrated** with the NestJS backend API:

- ✅ **Authentication endpoints** - Login, registration, profile management
- ✅ **Question management** - CRUD operations for questions
- ✅ **Chat system** - Real-time messaging with polling
- ✅ **File uploads** - Image upload for questions
- ✅ **User profiles** - Student and tutor profile management

### Environment Setup

For development, ensure your NestJS backend is running on `http://localhost:3000`

## 🧪 Testing

### Running Tests

```bash
flutter test
```

### Test Coverage

- Unit tests for providers
- Widget tests for screens
- Integration tests for user flows

## 📱 Platform Support

- ✅ **Android** (API 21+)
- ✅ **iOS** (iOS 12+)
- 🔄 **Web** (Future consideration)

## 🔄 Next Steps

### Immediate Enhancements

1. **WebSocket Integration** - Replace polling with real-time WebSocket connections
2. **Push Notifications** - Firebase Cloud Messaging for background notifications
3. **Video Calling** - Integrate video chat for tutoring sessions
4. **Payment Integration** - Add payment processing for tutoring sessions
5. **Advanced Filtering** - Enhanced search and filtering options

### Future Enhancements

1. **Offline Support** - Cached data and offline message queue
2. **Advanced UI** - Animations and micro-interactions
3. **Accessibility** - Screen reader and accessibility support
4. **Performance Optimization** - Image optimization and lazy loading
5. **Analytics** - User behavior tracking and insights
6. **Multi-language Support** - Internationalization (i18n)

## 🤝 Contributing

1. Follow the established code structure
2. Use the existing theme system
3. Add proper error handling
4. Write tests for new features
5. Update documentation

## 📄 License

This project is part of the Tejas Online Tutoring Platform.

---

**Built with ❤️ using Flutter for the Tejas Online Tutoring Platform**
