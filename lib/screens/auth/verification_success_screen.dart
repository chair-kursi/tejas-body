import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../providers/auth_provider.dart';
import '../onboarding/language_selection_screen.dart';
import '../tutor_onboarding/tutor_language_selection_screen.dart';

class VerificationSuccessScreen extends StatelessWidget {
  const VerificationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print('🎯 REACHED VERIFICATION SUCCESS SCREEN!');
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Verification success',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Success icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.success.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 60,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Success title
                    Text(
                      'Success!',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Success message
                    Text(
                      'Congratulations! You have been\nsuccessfully authenticated',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Continue button
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return CustomButton(
                    text: 'Continue',
                    isEnabled: true,
                    onPressed: () {
                      print('🎯 CONTINUE BUTTON PRESSED ON VERIFICATION SUCCESS!');
                      print('🎯 User role: ${authProvider.userRole}');
                      // Navigate to appropriate onboarding flow based on role
                      if (authProvider.userRole == UserRole.student) {
                        print('🎯 Navigating to student onboarding...');
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LanguageSelectionScreen(),
                          ),
                        );
                      } else if (authProvider.userRole == UserRole.tutor) {
                        print('🎯 Navigating to tutor onboarding...');
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TutorLanguageSelectionScreen(),
                          ),
                        );
                      }
                    },
                  );
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
