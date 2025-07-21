import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/tutor_onboarding_provider.dart';
import '../../widgets/custom_button.dart';
import 'availability_check_screen.dart';

class QuestionSolvingVideoScreen extends StatefulWidget {
  const QuestionSolvingVideoScreen({super.key});

  @override
  State<QuestionSolvingVideoScreen> createState() => _QuestionSolvingVideoScreenState();
}

class _QuestionSolvingVideoScreenState extends State<QuestionSolvingVideoScreen> {
  String? _questionVideoPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Question solving video'),
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
                        'Please upload the video of\nyour question-solving process\nas requested',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      const SizedBox(height: 40),
                      
                      // Video Upload Section
                      _buildVideoUploadSection(),
                      const SizedBox(height: 32),
                      
                      // Illustration
                      Center(
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: AppColors.backgroundSecondary,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Illustration placeholder
                              Container(
                                width: 120,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.play_circle_outline,
                                  size: 40,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Person illustration
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.person,
                                  size: 30,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Instructions
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
                              'Instructions:',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '• Record yourself solving a sample question\n'
                              '• Explain your thought process clearly\n'
                              '• Show your working step by step\n'
                              '• Keep the video under 5 minutes\n'
                              '• Ensure good audio and video quality',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.5,
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
                  provider.setQuestionSolvingVideo(_questionVideoPath ?? 'dummy_question_solving_video.mp4');

                  print('🎓 Question solving video screen - continuing with dummy video for testing');

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AvailabilityCheckScreen(),
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
          'Upload Question solving Video (max 5 min)',
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
                color: _questionVideoPath != null ? AppColors.success : AppColors.border,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(12),
              color: AppColors.backgroundSecondary,
            ),
            child: _questionVideoPath != null
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
      _questionVideoPath = 'mock_question_solving_video.mp4';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mock question solving video selected')),
    );
  }
}
