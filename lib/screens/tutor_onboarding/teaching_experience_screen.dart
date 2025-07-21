import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/tutor_onboarding_provider.dart';
import '../../widgets/custom_button.dart';
import 'tutor_class_selection_screen.dart';

class TeachingExperienceScreen extends StatefulWidget {
  const TeachingExperienceScreen({super.key});

  @override
  State<TeachingExperienceScreen> createState() => _TeachingExperienceScreenState();
}

class _TeachingExperienceScreenState extends State<TeachingExperienceScreen> {
  String? _selectedExperience;
  final TextEditingController _experienceController = TextEditingController();

  final List<String> _experienceOptions = [
    'Teaching Experience',
    'No Experience',
    'Less than 1 year',
    '1-3 years',
    '3-5 years',
    '5+ years',
  ];

  @override
  void dispose() {
    _experienceController.dispose();
    super.dispose();
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
        title: const Text('Teaching Experience'),
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
                        'Kindly share your teaching\nexperience for profile\nevaluation',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      const SizedBox(height: 40),
                      
                      // Experience dropdown
                      Text(
                        'Enter your years of teaching experience',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
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
                            value: _selectedExperience,
                            hint: Text(
                              'Teaching Experience',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            isExpanded: true,
                            items: _experienceOptions.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedExperience = newValue;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Experience description
                      Text(
                        'How you taught any one previously? If yes, please share the details',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.backgroundSecondary,
                        ),
                        child: TextField(
                          controller: _experienceController,
                          maxLines: 6,
                          decoration: InputDecoration(
                            hintText: 'Like Academic, BYJU\'S, Chegg etc.',
                            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Continue button
              CustomButton(
                text: 'Continue',
                isEnabled: _selectedExperience != null && _selectedExperience != 'Teaching Experience',
                onPressed: () {
                  if (_selectedExperience != null && _selectedExperience != 'Teaching Experience') {
                    final provider = Provider.of<TutorOnboardingProvider>(context, listen: false);
                    final experienceData = {
                      'level': _selectedExperience!,
                      'description': _experienceController.text.trim(),
                    };
                    provider.setTeachingExperience(experienceData.toString());
                    
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TutorClassSelectionScreen(),
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
}
