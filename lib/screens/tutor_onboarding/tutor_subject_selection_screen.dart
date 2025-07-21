import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/tutor_onboarding_provider.dart';
import '../../widgets/custom_button.dart';
import 'document_upload_screen.dart';

class TutorSubjectSelectionScreen extends StatefulWidget {
  const TutorSubjectSelectionScreen({super.key});

  @override
  State<TutorSubjectSelectionScreen> createState() => _TutorSubjectSelectionScreenState();
}

class _TutorSubjectSelectionScreenState extends State<TutorSubjectSelectionScreen> {
  final Set<String> _selectedSubjects = {};
  final TextEditingController _subjectController = TextEditingController();

  final List<String> _subjects = [
    'Maths',
    'Physics',
    'English',
    'Biology',
    'Chemistry',
    'Hindi',
    'History',
    'Geography',
    'Economics',
    'Political Science',
    'Computer Science',
    'Accountancy',
    'Business Studies',
  ];

  @override
  void dispose() {
    _subjectController.dispose();
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
        title: const Text('Subject selection'),
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
                        'Which subjects are you\nqualified and comfortable\nteaching?',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      const SizedBox(height: 16),
                      
                      // Subtitle
                      Text(
                        'Enter Subjects',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Custom subject input
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.backgroundSecondary,
                        ),
                        child: TextField(
                          controller: _subjectController,
                          decoration: InputDecoration(
                            hintText: 'Like Maths, Physics, English, Biology etc.',
                            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.add, color: AppColors.primary),
                              onPressed: () {
                                final subject = _subjectController.text.trim();
                                if (subject.isNotEmpty && !_selectedSubjects.contains(subject)) {
                                  setState(() {
                                    _selectedSubjects.add(subject);
                                    _subjectController.clear();
                                  });
                                }
                              },
                            ),
                          ),
                          style: Theme.of(context).textTheme.bodyMedium,
                          onSubmitted: (value) {
                            final subject = value.trim();
                            if (subject.isNotEmpty && !_selectedSubjects.contains(subject)) {
                              setState(() {
                                _selectedSubjects.add(subject);
                                _subjectController.clear();
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Selected subjects
                      if (_selectedSubjects.isNotEmpty) ...[
                        Text(
                          'Selected Subjects:',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _selectedSubjects.map((subject) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.primary),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  subject,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedSubjects.remove(subject);
                                    });
                                  },
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          )).toList(),
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      // Quick select subjects
                      Text(
                        'Quick Select:',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _subjects.map((subject) => GestureDetector(
                          onTap: () {
                            if (!_selectedSubjects.contains(subject)) {
                              setState(() {
                                _selectedSubjects.add(subject);
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: _selectedSubjects.contains(subject) 
                                  ? AppColors.primary.withOpacity(0.1)
                                  : AppColors.backgroundSecondary,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _selectedSubjects.contains(subject) 
                                    ? AppColors.primary 
                                    : AppColors.border,
                              ),
                            ),
                            child: Text(
                              subject,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: _selectedSubjects.contains(subject) 
                                    ? AppColors.primary 
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Continue button
              CustomButton(
                text: 'Continue',
                isEnabled: _selectedSubjects.isNotEmpty,
                onPressed: () {
                  if (_selectedSubjects.isNotEmpty) {
                    final provider = Provider.of<TutorOnboardingProvider>(context, listen: false);
                    provider.setSelectedSubjects(_selectedSubjects.toList());
                    
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DocumentUploadScreen(),
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
