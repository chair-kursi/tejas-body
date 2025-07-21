import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/tutor_onboarding_provider.dart';
import '../../widgets/custom_button.dart';
import 'educational_qualification_screen.dart';

class TutorLanguageSelectionScreen extends StatefulWidget {
  const TutorLanguageSelectionScreen({super.key});

  @override
  State<TutorLanguageSelectionScreen> createState() => _TutorLanguageSelectionScreenState();
}

class _TutorLanguageSelectionScreenState extends State<TutorLanguageSelectionScreen> {
  final Set<String> _selectedLanguages = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Language selection'),
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
                        'Choose Your Preferred\nLanguage of Educating',
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
                      
                      // Language options
                      _buildLanguageOption(
                        'English',
                        'Hello !',
                        _selectedLanguages.contains('English'),
                        () {
                          setState(() {
                            if (_selectedLanguages.contains('English')) {
                              _selectedLanguages.remove('English');
                            } else {
                              _selectedLanguages.add('English');
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      _buildLanguageOption(
                        'Hindi',
                        'नमस्ते',
                        _selectedLanguages.contains('Hindi'),
                        () {
                          setState(() {
                            if (_selectedLanguages.contains('Hindi')) {
                              _selectedLanguages.remove('Hindi');
                            } else {
                              _selectedLanguages.add('Hindi');
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              // Continue button
              CustomButton(
                text: 'Continue',
                isEnabled: _selectedLanguages.isNotEmpty,
                onPressed: () {
                  if (_selectedLanguages.isNotEmpty) {
                    final provider = Provider.of<TutorOnboardingProvider>(context, listen: false);
                    provider.setLanguages(_selectedLanguages.toList());
                    
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EducationalQualificationScreen(),
                      ),
                    );
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

  Widget _buildLanguageOption(String language, String greeting, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
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
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 12,
                      color: Colors.white,
                    )
                  : null,
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
    );
  }
}
