import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/tutor_onboarding_provider.dart';
import '../../widgets/custom_button.dart';
import 'question_solving_video_screen.dart';

class TutorTestScreen extends StatefulWidget {
  const TutorTestScreen({super.key});

  @override
  State<TutorTestScreen> createState() => _TutorTestScreenState();
}

class _TutorTestScreenState extends State<TutorTestScreen> {
  String? _introVideoPath;
  bool _testStarted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Tutor test'),
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
                      
                      // Title
                      Text(
                        'You will now be tested for the\nTejas Tutor Test',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      const SizedBox(height: 40),
                      
                      // Video Upload Section
                      _buildVideoUploadSection(),
                      const SizedBox(height: 32),
                      
                      // Test Instructions
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundSecondary,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Test Instructions:',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Upon clicking \'Get Started,\' your MCQ test will begin, consisting of 10 questions for each subject you selected. Your video will start recording automatically, and you will be asked to upload it after completing the test.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Get Started Button
                            Center(
                              child: Container(
                                width: 140,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () {
                                      setState(() {
                                        _testStarted = true;
                                      });
                                      _showTestDialog();
                                    },
                                    child: Center(
                                      child: Text(
                                        'GET STARTED',
                                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Continue button (temporarily allow skipping video upload for testing)
              CustomButton(
                text: 'Continue (Skip for now)',
                isEnabled: true, // Always enabled for testing
                onPressed: () {
                  final provider = Provider.of<TutorOnboardingProvider>(context, listen: false);
                  // Set dummy path for testing if no video uploaded
                  provider.setIntroVideo(_introVideoPath ?? 'dummy_intro_video.mp4');

                  print('🎓 Tutor test screen - continuing with dummy video for testing');

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QuestionSolvingVideoScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Self Introduction Video (max 1 min)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        GestureDetector(
          onTap: _pickVideo,
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(
                color: _introVideoPath != null ? AppColors.success : AppColors.border,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(12),
              color: AppColors.backgroundSecondary,
            ),
            child: _introVideoPath != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.video_library,
                        size: 32,
                        color: AppColors.success,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Video Uploaded',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap to change',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 32,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Click to Upload',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '(Max. File size: 25 MB)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickVideo() async {
    // TODO: Implement video picker when needed
    setState(() {
      _introVideoPath = 'mock_intro_video.mp4';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mock intro video selected')),
    );
  }

  void _showTestDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Test Started'),
          content: const Text('Your test has begun. The video recording will start automatically. Good luck!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Here you would typically navigate to the actual test screen
                // For now, we'll just simulate test completion
                Future.delayed(const Duration(seconds: 2), () {
                  _showTestCompletedDialog();
                });
              },
              child: const Text('Start Test'),
            ),
          ],
        );
      },
    );
  }

  void _showTestCompletedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Test Completed'),
          content: const Text('Congratulations! You have completed the test. Please proceed to upload your question-solving video.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }
}
