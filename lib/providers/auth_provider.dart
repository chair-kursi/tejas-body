import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

enum AuthState { initial, loading, success, error }
enum UserRole { student, tutor }
enum Gender { male, female, others, preferNotToSay }

class AuthProvider with ChangeNotifier {
  AuthState _state = AuthState.initial;
  String? _errorMessage;
  String? _phoneNumber;
  String? _countryCode;
  String? _email;
  String? _password;
  String? _fullName;
  Gender? _gender;
  UserRole? _userRole;
  bool _isLoggedIn = false;
  bool _isRegistrationMode = true; // true for signup, false for login

  // Getters
  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  String? get phoneNumber => _phoneNumber;
  String? get countryCode => _countryCode;
  String? get email => _email;
  String? get password => _password;
  String? get fullName => _fullName;
  Gender? get gender => _gender;
  UserRole? get userRole => _userRole;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _state == AuthState.loading;
  bool get isRegistrationMode => _isRegistrationMode;

  // Set registration/login mode
  void setRegistrationMode(bool isRegistration) {
    _isRegistrationMode = isRegistration;
    notifyListeners();
  }

  // Phone number and country code
  void setPhoneNumber(String phone, String country) {
    _phoneNumber = phone;
    _countryCode = country;
    notifyListeners();
  }

  // Email and password
  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void setPassword(String password) {
    _password = password;
    notifyListeners();
  }

  // Send OTP (after registration)
  Future<void> sendOTP() async {
    if (_phoneNumber == null || _phoneNumber!.isEmpty || _countryCode == null) {
      _setError('Please enter a valid phone number');
      return;
    }

    _setState(AuthState.loading);

    try {
      final mobileNumber = '$_countryCode$_phoneNumber';
      final response = await ApiService().sendOTP(mobileNumber: mobileNumber);

      _setState(AuthState.success);
    } catch (e) {
      _setError('Failed to send OTP. Please try again.');
    }
  }

  // Verify OTP
  Future<void> verifyOTP(String otp) async {
    if (otp.length != AppConstants.otpLength) {
      _setError('Please enter a valid ${AppConstants.otpLength}-digit OTP');
      return;
    }

    if (_phoneNumber == null || _countryCode == null) {
      _setError('Phone number not found');
      return;
    }

    _setState(AuthState.loading);

    try {
      final mobileNumber = '$_countryCode$_phoneNumber';
      final response = await ApiService().verifyOTP(
        mobileNumber: mobileNumber,
        verificationCode: otp,
      );

      // Store tokens if provided
      if (response['access_token'] != null) {
        await StorageService.setAccessToken(response['access_token']);
      }

      _isLoggedIn = true;
      _setState(AuthState.success);
    } catch (e) {
      _setError('Invalid OTP. Please try again.');
    }
  }

  // Set user details
  void setUserDetails(String name, Gender selectedGender) {
    _fullName = name;
    _gender = selectedGender;
    notifyListeners();
  }

  // Set user role
  void setUserRole(UserRole role) {
    _userRole = role;
    notifyListeners();
  }

  // Complete registration (called after role selection)
  Future<void> completeRegistration() async {
    if (_phoneNumber == null || _countryCode == null || _email == null ||
        _password == null || _gender == null || _userRole == null) {
      _setError('Please complete all required fields');
      return;
    }

    _setState(AuthState.loading);

    try {
      final mobileNumber = '$_countryCode$_phoneNumber';
      final response = await ApiService().register(
        mobileNumber: mobileNumber,
        email: _email!,
        password: _password!,
        gender: _gender!.name,
        role: _userRole!.name,
      );

      // Store tokens
      if (response['access_token'] != null) {
        await StorageService.setAccessToken(response['access_token']);
      }

      // Store user data
      if (response['user'] != null) {
        await StorageService.setUserData(response['user']);
      }

      _setState(AuthState.success);
    } catch (e) {
      _setError('Registration failed. Please try again.');
    }
  }

  // Login with existing account
  Future<void> login() async {
    if (_email == null || _email!.isEmpty || _password == null || _password!.isEmpty) {
      _setError('Please enter your email and password');
      return;
    }

    _setState(AuthState.loading);

    try {
      final response = await ApiService().login(
        email: _email!,
        password: _password!,
      );

      // Store tokens
      if (response['access_token'] != null) {
        await StorageService.setAccessToken(response['access_token']);
      }

      // Store user data and load user info
      if (response['user'] != null) {
        await StorageService.setUserData(response['user']);
        await _loadUserDataFromStorage();

        // Check if user has completed profile creation
        await _checkAndSetProfileCompletion();
      }

      _isLoggedIn = true;
      _setState(AuthState.success);
    } catch (e) {
      _setError('Login failed. Please check your credentials.');
    }
  }

  // Mark user as logged in (for OTP verification)
  void markAsLoggedIn() {
    _isLoggedIn = true;
    notifyListeners();
  }

  // Resend OTP
  Future<void> resendOTP() async {
    if (_phoneNumber == null || _phoneNumber!.isEmpty || _countryCode == null) {
      _setError('Phone number not found');
      return;
    }

    _setState(AuthState.loading);

    try {
      final mobileNumber = '$_countryCode$_phoneNumber';
      await ApiService().resendOTP(mobileNumber: mobileNumber);

      _setState(AuthState.success);
    } catch (e) {
      _setError('Failed to resend OTP. Please try again.');
    }
  }

  // Initialize auth state from storage
  Future<void> initializeFromStorage() async {
    try {
      final isLoggedIn = StorageService.isLoggedIn();
      if (isLoggedIn) {
        await _loadUserDataFromStorage();
        _isLoggedIn = true;

        // Check if user has completed profile creation
        await _checkAndSetProfileCompletion();
      }
    } catch (e) {
      print('🎯 Error initializing auth from storage: $e');
    }
  }

  // Load user data from storage
  Future<void> _loadUserDataFromStorage() async {
    try {
      final userData = await StorageService.getUserData();
      if (userData != null) {
        _email = userData['email'];
        _fullName = userData['fullName'];

        // Parse role
        if (userData['role'] != null) {
          final roleString = userData['role'].toString();
          if (roleString == 'student') {
            _userRole = UserRole.student;
          } else if (roleString == 'tutor') {
            _userRole = UserRole.tutor;
          }
        }

        // Parse gender
        if (userData['gender'] != null) {
          final genderString = userData['gender'].toString();
          for (Gender gender in Gender.values) {
            if (gender.name == genderString) {
              _gender = gender;
              break;
            }
          }
        }

        // Extract phone number if available
        if (userData['mobileNumber'] != null) {
          final mobileNumber = userData['mobileNumber'].toString();
          if (mobileNumber.startsWith('+')) {
            // Extract country code and phone number
            final parts = mobileNumber.substring(1); // Remove +
            if (parts.length > 2) {
              _countryCode = '+${parts.substring(0, 2)}'; // Assume 2-digit country code
              _phoneNumber = parts.substring(2);
            }
          }
        }


      }
    } catch (e) {
      print('🎯 Error loading user data from storage: $e');
    }
  }

  // Get user data from storage (public method)
  Future<Map<String, dynamic>?> getUserDataFromStorage() async {
    try {
      return await StorageService.getUserData();
    } catch (e) {
      print('🎯 Error getting user data from storage: $e');
      return null;
    }
  }

  // Check if user has completed profile creation and set onboarding status
  Future<void> _checkAndSetProfileCompletion() async {
    try {
      if (_userRole == UserRole.student) {
        // Check if student profile exists
        final hasProfile = await ApiService().checkStudentProfile();
        if (hasProfile) {
          await StorageService.setOnboardingComplete(true);
        }
      } else if (_userRole == UserRole.tutor) {
        // Check if tutor profile exists
        final hasProfile = await ApiService().checkTutorProfile();
        if (hasProfile) {
          await StorageService.setOnboardingComplete(true);
        }
      }
    } catch (e) {
      print('🎯 Error checking profile completion: $e');
      // If we can't check, assume onboarding is needed for safety
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoggedIn = false;
    _fullName = null;
    _gender = null;
    _userRole = null;
    _phoneNumber = null;
    _countryCode = null;
    _email = null;
    _password = null;

    // Clear stored data
    await StorageService.clearTokens();
    await StorageService.clearUserData();

    _setState(AuthState.initial);
  }

  // Reset state
  void resetState() {
    _setState(AuthState.initial);
    _errorMessage = null;
  }

  // Private methods
  void _setState(AuthState newState) {
    _state = newState;
    if (newState != AuthState.error) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _setState(AuthState.error);
  }

  // Validation helpers
  bool get canProceedWithPhone =>
      _phoneNumber != null && _phoneNumber!.isNotEmpty && _countryCode != null;

  bool get canProceedWithRegistrationData =>
      canProceedWithPhone && _email != null && _email!.isNotEmpty &&
      _password != null && _password!.isNotEmpty;

  bool get canProceedWithUserDetails =>
      _fullName != null && _fullName!.isNotEmpty && _gender != null;

  bool get canCompleteRegistration =>
      canProceedWithRegistrationData && canProceedWithUserDetails && _userRole != null;

  bool get canLogin =>
      _email != null && _email!.isNotEmpty && _password != null && _password!.isNotEmpty;

  // Gender helper methods
  String getGenderDisplayName(Gender gender) {
    switch (gender) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.others:
        return 'Others';
      case Gender.preferNotToSay:
        return 'Prefer not to say';
    }
  }

  // Role helper methods
  String getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.student:
        return 'Student';
      case UserRole.tutor:
        return 'Educator';
    }
  }

  String getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.student:
        return 'Learn instantly from expert tutors and\nclear your doubts anytime.';
      case UserRole.tutor:
        return 'Share your knowledge, help students grow,\nand earn on your schedule.';
    }
  }
}
