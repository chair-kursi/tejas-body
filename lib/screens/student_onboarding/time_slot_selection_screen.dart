import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/custom_button.dart';
import 'academic_stream_selection_screen.dart';

class TimeSlotSelectionScreen extends StatefulWidget {
  const TimeSlotSelectionScreen({super.key});

  @override
  State<TimeSlotSelectionScreen> createState() => _TimeSlotSelectionScreenState();
}

class _TimeSlotSelectionScreenState extends State<TimeSlotSelectionScreen> {
  @override
  void initState() {
    super.initState();
    print('🎯 REACHED TIME SLOT SELECTION SCREEN (second to last)!');
  }

  String? _selectedTimeSlot;

  final List<Map<String, String>> timeSlots = [
    {'value': 'morning', 'label': 'Morning (6:00 AM - 12:00 PM)', 'description': 'Best for early birds'},
    {'value': 'afternoon', 'label': 'Afternoon (12:00 PM - 6:00 PM)', 'description': 'Perfect for focused learning'},
    {'value': 'evening', 'label': 'Evening (6:00 PM - 10:00 PM)', 'description': 'Great for after school/work'},
    {'value': 'night', 'label': 'Night (10:00 PM - 12:00 AM)', 'description': 'For night owls'},
    {'value': 'flexible', 'label': 'Flexible', 'description': 'Any time that works for you'},
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
                        'Which time slot works best for\nyou to take a session?',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      const SizedBox(height: 16),
                      
                      // Subtitle
                      Text(
                        'This Will Help Us Customize Your Learning\nExperience',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // Time slot dropdown
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
                            value: _selectedTimeSlot,
                            hint: Text(
                              'Select Session Slot',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                            items: timeSlots.map((Map<String, String> slot) {
                              return DropdownMenuItem<String>(
                                value: slot['value'],
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      slot['label']!,
                                      style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    Text(
                                      slot['description']!,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedTimeSlot = newValue;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 60),
                      
                      // Illustration placeholder
                      Center(
                        child: Container(
                          height: 200,
                          child: Image.asset(
                            'assets/images/time_illustration.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.schedule,
                                size: 100,
                                color: AppColors.primary,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Continue button
              CustomButton(
                text: 'Continue',
                isEnabled: _selectedTimeSlot != null,
                onPressed: () {
                  if (_selectedTimeSlot != null) {
                    final provider = Provider.of<OnboardingProvider>(context, listen: false);
                    final selectedSlot = timeSlots.firstWhere(
                      (slot) => slot['value'] == _selectedTimeSlot,
                    );
                    provider.setTimeSlot(selectedSlot['label']!);
                    
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AcademicStreamSelectionScreen(),
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
