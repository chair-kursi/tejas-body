import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/class_option.dart';
import 'stream_selection_screen.dart';

class ClassSelectionScreen extends StatelessWidget {
  const ClassSelectionScreen({super.key});

  static const List<String> classOptions = [
    'Class 6',
    'Class 7',
    'Class 8',
    'Class 9',
    'Class 10',
    'Class 11',
    'Class 12',
    'Undergraduate',
    'Government Job Aspirant',
  ];

  @override
  Widget build(BuildContext context) {
    print('🎯 REACHED CLASS SELECTION SCREEN!');
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Class Selection',
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
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          
                          // Title
                          Text(
                            'What\'s your current\nacademic level?',
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                          const SizedBox(height: 40),
                          
                          // Class options
                          ...classOptions.map((classLevel) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: ClassOption(
                              classLevel: classLevel,
                              isSelected: onboardingProvider.selectedClass == classLevel,
                              onTap: () {
                                print('🎯 Class option tapped: $classLevel');
                                onboardingProvider.setClass(classLevel);
                              },
                            ),
                          )),
                        ],
                      ),
                    ),
                  ),
                  
                  // Continue button
                  CustomButton(
                    text: 'Continue',
                    isEnabled: onboardingProvider.canProceedFromClass,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StreamSelectionScreen(),
                        ),
                      );
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
