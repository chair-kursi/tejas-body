import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/custom_button.dart';
import 'time_slot_selection_screen.dart';

class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({super.key});

  @override
  State<LocationSelectionScreen> createState() => _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  final TextEditingController _locationController = TextEditingController();
  bool _isLocationEntered = false;

  @override
  void initState() {
    super.initState();
    _locationController.addListener(() {
      setState(() {
        _isLocationEntered = _locationController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  void _autoDetectLocation() {
    // Simulate location detection
    setState(() {
      _locationController.text = "Mumbai, Maharashtra";
      _isLocationEntered = true;
    });
    
    // Show a snackbar to indicate location detected
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Location detected successfully!'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );
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
                        'Where are you studying from ?',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      const SizedBox(height: 16),
                      
                      // Subtitle
                      Text(
                        'This helps us match you with the right\nteachers and materials.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // Location input field
                      TextField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          hintText: 'Enter Your Location',
                          hintStyle: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 16,
                          ),
                          filled: true,
                          fillColor: AppColors.backgroundSecondary,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primary, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                      
                      // OR divider
                      Row(
                        children: [
                          const Expanded(child: Divider(color: AppColors.border)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OR',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider(color: AppColors.border)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Auto-detect location button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _autoDetectLocation,
                          icon: const Icon(Icons.my_location, color: Colors.white),
                          label: const Text(
                            'Auto - Detect my location',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // Illustration
                      Center(
                        child: Container(
                          height: 200,
                          child: Image.asset(
                            'assets/images/location_illustration.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.location_on,
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
                isEnabled: _isLocationEntered,
                onPressed: () {
                  if (_isLocationEntered) {
                    final provider = Provider.of<OnboardingProvider>(context, listen: false);
                    provider.setLocation(_locationController.text.trim());
                    
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TimeSlotSelectionScreen(),
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
