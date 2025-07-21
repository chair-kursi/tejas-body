import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/custom_button.dart';
import '../../services/storage_service.dart';
import '../dashboard/student_dashboard_screen.dart';

class AcademicStreamSelectionScreen extends StatefulWidget {
  const AcademicStreamSelectionScreen({super.key});

  @override
  State<AcademicStreamSelectionScreen> createState() => _AcademicStreamSelectionScreenState();
}

class _AcademicStreamSelectionScreenState extends State<AcademicStreamSelectionScreen> {
  @override
  void initState() {
    super.initState();
    print('🎯 REACHED ACADEMIC STREAM SELECTION SCREEN!');
    print('🎯 This is the final onboarding screen');
    _checkUserToken();
  }

  void _checkUserToken() async {
    final token = StorageService.getAccessToken();
    final userData = StorageService.getUserData();
    print('🎯 User token check:');
    print('  - Token exists: ${token != null}');
    print('  - User data exists: ${userData != null}');
    print('  - Is logged in: ${StorageService.isLoggedIn()}');
    if (token != null) {
      print('  - Token preview: ${token.substring(0, 20)}...');
    }
    if (userData != null) {
      print('  - User role: ${userData['role']}');
      print('  - User email: ${userData['email']}');
    }
  }

  String? _selectedStream;

  final List<Map<String, String>> academicStreams = [
    {
      'value': 'science',
      'label': 'Science',
      'description': 'Physics, Chemistry, Mathematics, Biology',
      'icon': 'science'
    },
    {
      'value': 'commerce',
      'label': 'Commerce',
      'description': 'Accounts, Economics, Business Studies',
      'icon': 'business'
    },
    {
      'value': 'arts',
      'label': 'Arts/Humanities',
      'description': 'History, Geography, Political Science, Literature',
      'icon': 'palette'
    },
    {
      'value': 'others',
      'label': 'Others',
      'description': 'Competitive Exams, Skill Development',
      'icon': 'explore'
    },
  ];

  IconData _getStreamIcon(String iconName) {
    switch (iconName) {
      case 'science':
        return Icons.science;
      case 'business':
        return Icons.business;
      case 'palette':
        return Icons.palette;
      case 'explore':
        return Icons.explore;
      default:
        return Icons.school;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      
                      // Title with graduation cap icon
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Select Your Academic Stream\nto Personalize Your Learning\nJourney',
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                          ),
                          const Icon(
                            Icons.school,
                            size: 40,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Subtitle
                      Text(
                        'This helps us tailor the right content,\nmentors, and guidance just for you.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // Academic stream dropdown
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.backgroundSecondary,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedStream,
                            hint: Text(
                              'Select Academic Stream',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                            items: academicStreams.map((Map<String, String> stream) {
                              return DropdownMenuItem<String>(
                                value: stream['value'],
                                child: Row(
                                  children: [
                                    Icon(
                                      _getStreamIcon(stream['icon']!),
                                      color: AppColors.primary,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            stream['label']!,
                                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            stream['description']!,
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedStream = newValue;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 60),
                      
                      // Illustration placeholder
                      Center(
                        child: Container(
                          height: 150,
                          child: Image.asset(
                            'assets/images/academic_illustration.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.school,
                                size: 80,
                                color: AppColors.primary,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Test API button
              ElevatedButton(
                onPressed: () async {
                  print('🧪 TEST API BUTTON PRESSED!');
                  final provider = Provider.of<OnboardingProvider>(context, listen: false);

                  // Set some test data
                  provider.setLanguage('English');
                  provider.setClass('Class 12');
                  provider.setStream('Science');
                  provider.setLocation('Mumbai');
                  provider.setTargetExam('JEE Main');

                  final success = await provider.createStudentProfile();
                  print('🧪 Test API result: $success');

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'API Test Success!' : 'API Test Failed!'),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                },
                child: const Text('🧪 TEST API'),
              ),

              const SizedBox(height: 20),

              // Continue button
              CustomButton(
                text: 'Continue',
                isEnabled: _selectedStream != null,
                onPressed: () async {
                  print('🔥 CONTINUE BUTTON PRESSED!');
                  if (_selectedStream != null) {
                    print('🔥 Selected stream: $_selectedStream');
                    final provider = Provider.of<OnboardingProvider>(context, listen: false);
                    final selectedStreamData = academicStreams.firstWhere(
                      (stream) => stream['value'] == _selectedStream,
                    );
                    provider.setAcademicStream(selectedStreamData['label']!);
                    print('🔥 About to call createStudentProfile...');

                    // Create student profile via API
                    final success = await provider.createStudentProfile();
                    print('🔥 createStudentProfile result: $success');

                    if (success) {
                      provider.completeOnboarding();
                      print('🔥 Navigating to dashboard...');

                      // Navigate to dashboard
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StudentDashboardScreen(),
                        ),
                        (route) => false,
                      );
                    } else {
                      print('🔥 Showing error message...');
                      // Show error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to create profile. Please try again.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } else {
                    print('🔥 No stream selected!');
                  }
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
