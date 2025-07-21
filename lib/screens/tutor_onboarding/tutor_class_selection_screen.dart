import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/tutor_onboarding_provider.dart';
import '../../widgets/custom_button.dart';
import 'tutor_subject_selection_screen.dart';

class TutorClassSelectionScreen extends StatefulWidget {
  const TutorClassSelectionScreen({super.key});

  @override
  State<TutorClassSelectionScreen> createState() => _TutorClassSelectionScreenState();
}

class _TutorClassSelectionScreenState extends State<TutorClassSelectionScreen> {
  final Set<String> _selectedClasses = {};

  final List<String> _classes = [
    'Class 6',
    'Class 7',
    'Class 8',
    'Class 9',
    'Class 10',
    'Class 11',
    'Class 12',
    'Class 12 Passed (Dropper)',
    'Undergraduate (B.Tech/BSc)',
    'Government Job Aspirant',
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
        title: const Text('Class Selection'),
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
                        'Which class levels are you\ncomfortable teaching?',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      const SizedBox(height: 16),
                      
                      // Subtitle
                      Text(
                        'Select the most suitable levels',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // Class options
                      ..._classes.map((className) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildClassOption(
                          className,
                          _selectedClasses.contains(className),
                          () {
                            setState(() {
                              if (_selectedClasses.contains(className)) {
                                _selectedClasses.remove(className);
                              } else {
                                _selectedClasses.add(className);
                              }
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
                isEnabled: _selectedClasses.isNotEmpty,
                onPressed: () {
                  if (_selectedClasses.isNotEmpty) {
                    final provider = Provider.of<TutorOnboardingProvider>(context, listen: false);
                    provider.setSelectedClasses(_selectedClasses.toList());
                    
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TutorSubjectSelectionScreen(),
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

  Widget _buildClassOption(String className, bool isSelected, VoidCallback onTap) {
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
              child: Text(
                className,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
