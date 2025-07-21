import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/tutor_onboarding_provider.dart';
import '../../widgets/custom_button.dart';
import 'teaching_experience_screen.dart';

class EducationalQualificationScreen extends StatefulWidget {
  const EducationalQualificationScreen({super.key});

  @override
  State<EducationalQualificationScreen> createState() => _EducationalQualificationScreenState();
}

class _EducationalQualificationScreenState extends State<EducationalQualificationScreen> {
  String? _selectedQualification;
  String? _selectedEducationLevel;

  final List<Map<String, String>> _qualifications = [
    {'title': 'Ongoing', 'subtitle': 'Currently pursuing'},
    {'title': 'Completed', 'subtitle': 'Degree completed'},
  ];

  final List<Map<String, String>> _educationLevels = [
    {'title': 'Secondary Graduate', 'subtitle': 'Class 10th completed'},
    {'title': 'Senior Secondary Graduate', 'subtitle': 'Class 12th completed'},
    {'title': 'Graduation', 'subtitle': 'Bachelor\'s degree'},
    {'title': 'Post Graduation', 'subtitle': 'Master\'s degree'},
    {'title': 'Highest educational qualification', 'subtitle': 'PhD, Doctorate'},
    {'title': 'Like MBA, B.Sc, B.Tech etc.', 'subtitle': 'Professional degrees'},
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
        title: const Text('Educational qualification'),
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
                        'Kindly share your educational\nqualifications to help us\nassess your teaching profile',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      const SizedBox(height: 40),
                      
                      // Education Status
                      Text(
                        'Education Status',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      ..._qualifications.map((qualification) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildQualificationOption(
                          qualification['title']!,
                          qualification['subtitle']!,
                          _selectedQualification == qualification['title'],
                          () {
                            setState(() {
                              _selectedQualification = qualification['title'];
                            });
                          },
                        ),
                      )),
                      
                      const SizedBox(height: 32),
                      
                      // Education Level
                      Text(
                        'Education Level',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      ..._educationLevels.map((level) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildQualificationOption(
                          level['title']!,
                          level['subtitle']!,
                          _selectedEducationLevel == level['title'],
                          () {
                            setState(() {
                              _selectedEducationLevel = level['title'];
                            });
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
                isEnabled: _selectedQualification != null && _selectedEducationLevel != null,
                onPressed: () {
                  if (_selectedQualification != null && _selectedEducationLevel != null) {
                    final provider = Provider.of<TutorOnboardingProvider>(context, listen: false);
                    final qualificationData = {
                      'status': _selectedQualification!,
                      'level': _selectedEducationLevel!,
                    };
                    provider.setEducationalQualification(qualificationData.toString());

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TeachingExperienceScreen(),
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

  Widget _buildQualificationOption(String title, String subtitle, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
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
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
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
