import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/language_option.dart';
import 'class_selection_screen.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print('🎯 REACHED LANGUAGE SELECTION SCREEN (first onboarding screen)!');
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Language Selection',
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
                        const SizedBox(height: 40),
                        
                        // Title
                        Text(
                          'Choose Your Preferred\nLanguage of Learning',
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        const SizedBox(height: 16),

                        // Subtitle
                        Text(
                          'Select any 1 or both of the languages',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Language options with enhanced design
                        _buildLanguageOption(
                          'English',
                          'Hello !',
                          onboardingProvider.selectedLanguage == 'English',
                          () => onboardingProvider.setLanguage('English'),
                        ),
                        const SizedBox(height: 16),

                        _buildLanguageOption(
                          'Hindi',
                          'नमस्ते',
                          onboardingProvider.selectedLanguage == 'Hindi',
                          () => onboardingProvider.setLanguage('Hindi'),
                        ),
                      ],
                    ),
                  ),
                  
                  // Continue button
                  CustomButton(
                    text: 'Continue',
                    isEnabled: onboardingProvider.canProceedFromLanguage,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ClassSelectionScreen(),
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

  Widget _buildLanguageOption(String language, String greeting, bool isSelected, VoidCallback onTap) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: AppColors.backgroundSecondary,
          ),
          child: Row(
            children: [
              Radio<bool>(
                value: true,
                groupValue: isSelected,
                onChanged: (_) => onTap(),
                activeColor: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      greeting,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
