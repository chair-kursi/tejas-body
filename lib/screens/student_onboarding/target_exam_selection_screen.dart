import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/custom_button.dart';
import 'location_selection_screen.dart';

class TargetExamSelectionScreen extends StatefulWidget {
  final String selectedStream;
  
  const TargetExamSelectionScreen({
    super.key,
    required this.selectedStream,
  });

  @override
  State<TargetExamSelectionScreen> createState() => _TargetExamSelectionScreenState();
}

class _TargetExamSelectionScreenState extends State<TargetExamSelectionScreen> {
  String? _selectedExam;

  Map<String, List<String>> get streamExams => {
    'Science (PCM)': [
      'JEE Main',
      'JEE Advanced',
      'BITSAT',
      'KVPY',
      'NTSE',
      'Olympiads',
      'Board Exams',
    ],
    'Science (PCB)': [
      'NEET',
      'AIIMS',
      'JIPMER',
      'KVPY',
      'NTSE',
      'Olympiads',
      'Board Exams',
    ],
    'Commerce': [
      'CA Foundation',
      'CS Foundation',
      'CMA Foundation',
      'CLAT',
      'BBA Entrance',
      'Economics Honors',
      'Board Exams',
    ],
    'Arts/Humanities': [
      'CLAT',
      'CUET',
      'JMI Entrance',
      'BFA Entrance',
      'Mass Communication',
      'Psychology Entrance',
      'Board Exams',
    ],
    'Engineering': [
      'JEE Main',
      'JEE Advanced',
      'BITSAT',
      'VITEEE',
      'SRMJEEE',
      'COMEDK',
      'MHT CET',
    ],
    'Medical': [
      'NEET',
      'AIIMS',
      'JIPMER',
      'NEET PG',
      'FMGE',
      'Board Exams',
    ],
    'Other': [
      'UPSC',
      'SSC',
      'Banking',
      'Railway',
      'State PSC',
      'Teaching',
      'Other Competitive',
    ],
  };

  String get streamDescription {
    switch (widget.selectedStream) {
      case 'Science (PCM)':
        return '"Master Physics, Chemistry & Mathematics for Engineering Excellence"';
      case 'Science (PCB)':
        return '"Explore Biology, Chemistry & Physics for Medical Sciences"';
      case 'Commerce':
        return '"Understand Business, Finance & the Economy with Clarity"';
      case 'Arts/Humanities':
        return '"Express Ideas, Culture & Humanity Through Creativity"';
      case 'Engineering':
        return '"Build Tomorrow\'s Technology Through Innovation & Design"';
      case 'Medical':
        return '"Heal Lives Through Medical Science & Healthcare Excellence"';
      case 'Other':
        return '"Forge Your Own Unique Path of Learning & Growth"';
      default:
        return '';
    }
  }

  Widget get streamIllustration {
    switch (widget.selectedStream) {
      case 'Science (PCM)':
        return Container(
          height: 200,
          child: const Icon(Icons.calculate, size: 100, color: AppColors.primary),
        );
      case 'Science (PCB)':
        return Container(
          height: 200,
          child: const Icon(Icons.biotech, size: 100, color: AppColors.primary),
        );
      case 'Commerce':
        return Container(
          height: 200,
          child: const Icon(Icons.business, size: 100, color: AppColors.primary),
        );
      case 'Arts/Humanities':
        return Container(
          height: 200,
          child: const Icon(Icons.palette, size: 100, color: AppColors.primary),
        );
      case 'Engineering':
        return Container(
          height: 200,
          child: const Icon(Icons.engineering, size: 100, color: AppColors.primary),
        );
      case 'Medical':
        return Container(
          height: 200,
          child: const Icon(Icons.medical_services, size: 100, color: AppColors.primary),
        );
      case 'Other':
        return Container(
          height: 200,
          child: const Icon(Icons.explore, size: 100, color: AppColors.primary),
        );
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🎯 TARGET EXAM SCREEN - selectedStream: "${widget.selectedStream}"');
    print('🎯 Available stream keys: ${streamExams.keys.toList()}');
    final exams = streamExams[widget.selectedStream] ?? [];
    print('🎯 Exams for this stream: $exams');
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
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
                        'Set Your Target Exam in the\n${widget.selectedStream} Stream',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      const SizedBox(height: 16),
                      
                      // Description
                      Text(
                        streamDescription,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Exam dropdown
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
                            value: _selectedExam,
                            hint: Text(
                              'Select your Target Exam',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                            items: exams.map((String exam) {
                              return DropdownMenuItem<String>(
                                value: exam,
                                child: Text(
                                  exam,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedExam = newValue;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // Illustration
                      Center(child: streamIllustration),
                    ],
                  ),
                ),
              ),
              
              // Continue button
              CustomButton(
                text: 'Continue',
                isEnabled: _selectedExam != null,
                onPressed: () {
                  if (_selectedExam != null) {
                    final provider = Provider.of<OnboardingProvider>(context, listen: false);
                    provider.setStream('${widget.selectedStream} - $_selectedExam');
                    provider.setTargetExam(_selectedExam!);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LocationSelectionScreen(),
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
