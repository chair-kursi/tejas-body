import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/custom_button.dart';
import '../student_onboarding/target_exam_selection_screen.dart';

class StreamSelectionScreen extends StatelessWidget {
  const StreamSelectionScreen({super.key});

  static const List<String> streamOptions = [
    'Science (PCM)',
    'Science (PCB)',
    'Commerce',
    'Arts/Humanities',
    'Engineering',
    'Medical',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Stream Selection',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Consumer<OnboardingProvider>(
            builder: (context, onboardingProvider, child) {
              return Column(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        
                        // Title
                        Text(
                          'Select your academic\nstream for personalized\nlearning journey',
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        const SizedBox(height: 40),
                        
                        // Stream dropdown
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
                              value: onboardingProvider.selectedStream,
                              hint: Text(
                                'Choose your stream',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                              items: streamOptions.map((String stream) {
                                return DropdownMenuItem<String>(
                                  value: stream,
                                  child: Text(
                                    stream,
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  onboardingProvider.setStream(newValue);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Continue button
                  CustomButton(
                    text: 'Continue',
                    isEnabled: onboardingProvider.canProceedFromStream,
                    onPressed: () {
                      if (onboardingProvider.selectedStream != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TargetExamSelectionScreen(
                              selectedStream: onboardingProvider.selectedStream!,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
