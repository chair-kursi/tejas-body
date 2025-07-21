import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class TutorOnboardingProvider with ChangeNotifier {
  List<String> _selectedLanguages = [];
  String? _educationalQualification;
  String? _teachingExperience;
  List<String> _selectedClasses = [];
  List<String> _selectedSubjects = [];
  String? _profilePhotoPath;
  String? _idProofPath;
  String? _qualificationCertificatePath;
  String? _introVideoPath;
  String? _questionSolvingVideoPath;
  List<String> _availableDays = [];
  String? _sessionSlot;
  bool _termsAccepted = false;
  bool _isOnboardingComplete = false;

  // Getters
  List<String> get selectedLanguages => _selectedLanguages;
  String? get educationalQualification => _educationalQualification;
  String? get teachingExperience => _teachingExperience;
  List<String> get selectedClasses => _selectedClasses;
  List<String> get selectedSubjects => _selectedSubjects;
  String? get profilePhotoPath => _profilePhotoPath;
  String? get idProofPath => _idProofPath;
  String? get qualificationCertificatePath => _qualificationCertificatePath;
  String? get introVideoPath => _introVideoPath;
  String? get questionSolvingVideoPath => _questionSolvingVideoPath;
  List<String> get availableDays => _availableDays;
  String? get sessionSlot => _sessionSlot;
  bool get termsAccepted => _termsAccepted;
  bool get isOnboardingComplete => _isOnboardingComplete;

  // Setters
  void setLanguages(List<String> languages) {
    _selectedLanguages = languages;
    notifyListeners();
  }

  void setEducationalQualification(String qualification) {
    _educationalQualification = qualification;
    notifyListeners();
  }

  void setTeachingExperience(String experience) {
    _teachingExperience = experience;
    notifyListeners();
  }

  void setSelectedClasses(List<String> classes) {
    _selectedClasses = classes;
    notifyListeners();
  }

  void setSelectedSubjects(List<String> subjects) {
    _selectedSubjects = subjects;
    notifyListeners();
  }

  void setProfilePhoto(String path) {
    _profilePhotoPath = path;
    notifyListeners();
  }

  void setIdProof(String path) {
    _idProofPath = path;
    notifyListeners();
  }

  void setQualificationCertificate(String path) {
    _qualificationCertificatePath = path;
    notifyListeners();
  }

  void setIntroVideo(String path) {
    _introVideoPath = path;
    notifyListeners();
  }

  void setQuestionSolvingVideo(String path) {
    _questionSolvingVideoPath = path;
    notifyListeners();
  }

  void setAvailableDays(List<String> days) {
    _availableDays = days;
    notifyListeners();
  }

  void setSessionSlot(String slot) {
    _sessionSlot = slot;
    notifyListeners();
  }

  void setTermsAccepted(bool accepted) {
    _termsAccepted = accepted;
    notifyListeners();
  }

  void completeOnboarding() {
    _isOnboardingComplete = true;
    notifyListeners();
  }

  // Validation methods
  bool get canProceedFromLanguages => _selectedLanguages.isNotEmpty;
  bool get canProceedFromQualification => _educationalQualification != null;
  bool get canProceedFromExperience => _teachingExperience != null;
  bool get canProceedFromClasses => _selectedClasses.isNotEmpty;
  bool get canProceedFromSubjects => _selectedSubjects.isNotEmpty;
  bool get canProceedFromDocuments => 
      _profilePhotoPath != null && 
      _idProofPath != null && 
      _qualificationCertificatePath != null;
  bool get canProceedFromIntroVideo => _introVideoPath != null;
  bool get canProceedFromQuestionVideo => _questionSolvingVideoPath != null;
  bool get canProceedFromAvailability => 
      _availableDays.isNotEmpty && _sessionSlot != null;
  bool get canProceedFromTerms => _termsAccepted;

  Map<String, dynamic> getTutorOnboardingData() {
    return {
      'languages': _selectedLanguages,
      'educationalQualification': _educationalQualification,
      'teachingExperience': _teachingExperience,
      'selectedClasses': _selectedClasses,
      'selectedSubjects': _selectedSubjects,
      'profilePhotoPath': _profilePhotoPath,
      'idProofPath': _idProofPath,
      'qualificationCertificatePath': _qualificationCertificatePath,
      'introVideoPath': _introVideoPath,
      'questionSolvingVideoPath': _questionSolvingVideoPath,
      'availableDays': _availableDays,
      'sessionSlot': _sessionSlot,
      'termsAccepted': _termsAccepted,
      'isComplete': _isOnboardingComplete,
    };
  }

  // Helper methods to map Flutter data to backend format
  String _mapEducationStatusToBackend(String? qualification) {
    if (qualification == null) return 'completed';
    if (qualification.toLowerCase().contains('ongoing')) {
      return 'ongoing';
    }
    return 'completed';
  }

  List<String> _mapDaysToBackend(List<String> days) {
    final dayMapping = {
      'Sun': 'sunday',
      'Mon': 'monday',
      'Tue': 'tuesday',
      'Wed': 'wednesday',
      'Thu': 'thursday',
      'Fri': 'friday',
      'Sat': 'saturday',
    };

    return days.map((day) => dayMapping[day] ?? day.toLowerCase()).toList();
  }

  List<String> _mapTimeSlotsToBackend(String? sessionSlot) {
    if (sessionSlot == null) return [];

    // Map session slots to backend format
    if (sessionSlot.contains('Morning')) {
      return ['6:00-7:00', '7:00-8:00', '8:00-9:00', '9:00-10:00', '10:00-11:00', '11:00-12:00'];
    } else if (sessionSlot.contains('Afternoon')) {
      return ['12:00-13:00', '13:00-14:00', '14:00-15:00', '15:00-16:00', '16:00-17:00', '17:00-18:00'];
    } else if (sessionSlot.contains('Evening')) {
      return ['18:00-19:00', '19:00-20:00', '20:00-21:00', '21:00-22:00'];
    } else if (sessionSlot.contains('Night')) {
      return ['22:00-23:00', '23:00-24:00', '0:00-1:00', '1:00-2:00', '2:00-3:00', '3:00-4:00', '4:00-5:00', '5:00-6:00'];
    }

    return ['9:00-10:00']; // Default slot
  }

  String _extractUniversityFromQualification(String? qualification) {
    if (qualification == null) return 'Not specified';

    // Try to extract university from qualification string
    // This is a simple implementation - you might want to make it more sophisticated
    if (qualification.contains('University')) {
      return qualification;
    }

    return 'Not specified';
  }

  String _extractHighestQualificationFromQualification(String? qualification) {
    if (qualification == null) return 'Not specified';

    // Extract the highest qualification from the stored string
    if (qualification.contains('Post Graduation')) {
      return 'Master\'s Degree';
    } else if (qualification.contains('Graduation')) {
      return 'Bachelor\'s Degree';
    } else if (qualification.contains('Senior Secondary')) {
      return 'Class 12th';
    } else if (qualification.contains('Secondary')) {
      return 'Class 10th';
    }

    return qualification;
  }

  // Create tutor profile via API
  Future<bool> createTutorProfile() async {
    print('🎓 createTutorProfile() called!');
    print('🎓 Current tutor onboarding data:');
    print('  - Languages: $_selectedLanguages');
    print('  - Educational Qualification: $_educationalQualification');
    print('  - Teaching Experience: $_teachingExperience');
    print('  - Selected Classes: $_selectedClasses');
    print('  - Selected Subjects: $_selectedSubjects');
    print('  - Available Days: $_availableDays');
    print('  - Session Slot: $_sessionSlot');
    print('  - Terms Accepted: $_termsAccepted');

    // Validate required fields
    if (_selectedLanguages.isEmpty ||
        _educationalQualification == null ||
        _teachingExperience == null ||
        _selectedClasses.isEmpty ||
        _selectedSubjects.isEmpty ||
        !_termsAccepted) {
      print('❌ Missing required fields for tutor profile creation');
      return false;
    }

    try {
      print('✅ All required fields present, making API call...');

      // Map data to backend format
      final educationStatus = _mapEducationStatusToBackend(_educationalQualification);
      final mappedDays = _mapDaysToBackend(_availableDays);
      final mappedSlots = _mapTimeSlotsToBackend(_sessionSlot);
      final university = _extractUniversityFromQualification(_educationalQualification);
      final highestQualification = _extractHighestQualificationFromQualification(_educationalQualification);

      print('🎓 Mapped data:');
      print('  - educationStatus: $educationStatus');
      print('  - mappedDays: $mappedDays');
      print('  - mappedSlots: $mappedSlots');
      print('  - university: $university');
      print('  - highestQualification: $highestQualification');

      final response = await ApiService().createTutorProfile(
        preferredLanguage: _selectedLanguages.first, // Use first selected language
        educationStatus: educationStatus,
        university: university,
        highestQualification: highestQualification,
        teachingExperience: _teachingExperience!,
        classLevelsCanTeach: _selectedClasses,
        subjects: _selectedSubjects,
        availableDays: mappedDays,
        availableSlots: mappedSlots,
        isTnCAgreement: _termsAccepted,
      );

      print('🎓 Tutor profile created successfully: ${response['message']}');
      _isOnboardingComplete = true;

      // Mark onboarding as complete in storage
      await StorageService.setOnboardingComplete(true);
      print('🎓 Onboarding marked as complete in storage');

      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Error creating tutor profile: $e');
      return false;
    }
  }

  void reset() {
    _selectedLanguages = [];
    _educationalQualification = null;
    _teachingExperience = null;
    _selectedClasses = [];
    _selectedSubjects = [];
    _profilePhotoPath = null;
    _idProofPath = null;
    _qualificationCertificatePath = null;
    _introVideoPath = null;
    _questionSolvingVideoPath = null;
    _availableDays = [];
    _sessionSlot = null;
    _termsAccepted = false;
    _isOnboardingComplete = false;
    notifyListeners();
  }
}
