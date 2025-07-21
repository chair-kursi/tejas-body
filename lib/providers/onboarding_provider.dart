import 'package:flutter/material.dart';
import '../services/api_service.dart';

class OnboardingProvider with ChangeNotifier {
  String? _selectedLanguage;
  String? _selectedClass;
  String? _selectedStream;
  String? _selectedLocation;
  String? _selectedTimeSlot;
  String? _selectedAcademicStream;
  String? _selectedName;
  String? _selectedTargetExam;
  bool _isOnboardingComplete = false;

  String? get selectedLanguage => _selectedLanguage;
  String? get selectedClass => _selectedClass;
  String? get selectedStream => _selectedStream;
  String? get selectedLocation => _selectedLocation;
  String? get selectedTimeSlot => _selectedTimeSlot;
  String? get selectedAcademicStream => _selectedAcademicStream;
  String? get selectedName => _selectedName;
  String? get selectedTargetExam => _selectedTargetExam;
  bool get isOnboardingComplete => _isOnboardingComplete;

  void setLanguage(String language) {
    _selectedLanguage = language;
    notifyListeners();
  }

  void setClass(String classLevel) {
    print('🎯 OnboardingProvider.setClass() called with: $classLevel');
    _selectedClass = classLevel;
    print('🎯 _selectedClass is now: $_selectedClass');
    notifyListeners();
  }

  void setStream(String stream) {
    _selectedStream = stream;
    notifyListeners();
  }

  void setLocation(String location) {
    _selectedLocation = location;
    notifyListeners();
  }

  void setTimeSlot(String timeSlot) {
    _selectedTimeSlot = timeSlot;
    notifyListeners();
  }

  void setAcademicStream(String academicStream) {
    _selectedAcademicStream = academicStream;
    notifyListeners();
  }

  void setName(String name) {
    _selectedName = name;
    notifyListeners();
  }

  void setTargetExam(String targetExam) {
    _selectedTargetExam = targetExam;
    notifyListeners();
  }

  void completeOnboarding() {
    _isOnboardingComplete = true;
    notifyListeners();
  }

  // Create student profile via API
  Future<bool> createStudentProfile() async {
    print('🚀 createStudentProfile() called!');
    print('🚀 Current onboarding data:');
    print('  - Language: $_selectedLanguage');
    print('  - Class: $_selectedClass');
    print('  - Stream: $_selectedStream');
    print('  - Location: $_selectedLocation');
    print('  - Target Exam: $_selectedTargetExam');
    print('  - Academic Stream: $_selectedAcademicStream');
    print('  - Name: $_selectedName');

    if (_selectedLanguage == null || _selectedClass == null) {
      print('❌ Missing required fields: language=$_selectedLanguage, class=$_selectedClass');
      return false;
    }

    try {
      print('✅ All required fields present, making API call...');
      print('🌐 API URL: http://localhost:3000/users/student/profile');
      print('📤 Request data:');
      print('  - preferredLanguage: $_selectedLanguage');
      print('  - academicLevel: $_selectedClass');
      print('  - academicSubLevel: $_selectedStream');
      print('  - targetExam: $_selectedTargetExam');
      print('  - location: $_selectedLocation');

      final response = await ApiService().createStudentProfile(
        preferredLanguage: _selectedLanguage!,
        academicLevel: _selectedClass!,
        academicSubLevel: _selectedStream,
        targetExam: _selectedTargetExam,
        location: _selectedLocation,
      );

      print('✅ Student profile created successfully!');
      print('📥 Response: $response');
      return true;
    } catch (e) {
      print('❌ Error creating student profile: $e');
      print('❌ Error type: ${e.runtimeType}');
      if (e.toString().contains('DioException')) {
        print('❌ This is a network/API error');
      }
      return false;
    }
  }

  bool get canProceedFromLanguage => _selectedLanguage != null;
  bool get canProceedFromClass => _selectedClass != null;
  bool get canProceedFromStream => _selectedStream != null;
  bool get canProceedFromLocation => _selectedLocation != null;
  bool get canProceedFromTimeSlot => _selectedTimeSlot != null;
  bool get canProceedFromAcademicStream => _selectedAcademicStream != null;

  Map<String, dynamic> getOnboardingData() {
    return {
      'name': _selectedName,
      'language': _selectedLanguage,
      'academicLevel': _selectedClass,
      'stream': _selectedStream,
      'location': _selectedLocation,
      'timeSlot': _selectedTimeSlot,
      'academicStream': _selectedAcademicStream,
      'targetExam': _selectedTargetExam,
      'isComplete': _isOnboardingComplete,
    };
  }

  void reset() {
    print('🎯 OnboardingProvider.reset() called! This will clear all data.');
    _selectedLanguage = null;
    _selectedClass = null;
    _selectedStream = null;
    _selectedLocation = null;
    _selectedTimeSlot = null;
    _selectedAcademicStream = null;
    _selectedName = null;
    _selectedTargetExam = null;
    _isOnboardingComplete = false;
    notifyListeners();
  }
}
