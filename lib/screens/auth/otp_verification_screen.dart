import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_overlay.dart';
import '../home/home_screen.dart';
import 'verification_success_screen.dart';

class OTPVerificationScreen extends StatefulWidget {
  final bool isLogin;

  const OTPVerificationScreen({super.key, this.isLogin = false});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  String _currentOTP = '';

  @override
  void dispose() {
    _otpController.dispose();
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
        title: Text(
          'OTP verification',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return LoadingOverlay(
            isLoading: authProvider.isLoading,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            
                            // Title
                            Text(
                              'Verification Code',
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                            const SizedBox(height: 16),
                            
                            // Subtitle
                            Text(
                              'We have sent the verification\ncode to your mobile number',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 40),
                            
                            // OTP Input
                            PinCodeTextField(
                              appContext: context,
                              length: AppConstants.otpLength,
                              controller: _otpController,
                              keyboardType: TextInputType.number,
                              animationType: AnimationType.fade,
                              pinTheme: PinTheme(
                                shape: PinCodeFieldShape.box,
                                borderRadius: BorderRadius.circular(12),
                                fieldHeight: 56,
                                fieldWidth: 48,
                                activeFillColor: AppColors.background,
                                inactiveFillColor: AppColors.backgroundSecondary,
                                selectedFillColor: AppColors.background,
                                activeColor: AppColors.primary,
                                inactiveColor: AppColors.border,
                                selectedColor: AppColors.primary,
                                borderWidth: 2,
                              ),
                              animationDuration: const Duration(milliseconds: 300),
                              backgroundColor: Colors.transparent,
                              enableActiveFill: true,
                              onCompleted: (value) {
                                setState(() {
                                  _currentOTP = value;
                                });
                              },
                              onChanged: (value) {
                                setState(() {
                                  _currentOTP = value;
                                });
                              },
                            ),
                            const SizedBox(height: 32),
                            
                            // Resend OTP
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Didn\'t receive the code? ',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                GestureDetector(
                                  onTap: () => _resendOTP(authProvider),
                                  child: Text(
                                    'Resend',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            if (authProvider.errorMessage != null) ...[
                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline, color: AppColors.error, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        authProvider.errorMessage!,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: AppColors.error,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    
                    // Confirm button
                    CustomButton(
                      text: 'Confirm',
                      isEnabled: _currentOTP.length == AppConstants.otpLength,
                      onPressed: () => _verifyOTP(authProvider),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _resendOTP(AuthProvider authProvider) async {
    authProvider.resetState();
    await authProvider.resendOTP();

    if (authProvider.state == AuthState.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _verifyOTP(AuthProvider authProvider) async {
    print('🎯 Starting OTP verification...');
    await authProvider.verifyOTP(_currentOTP);
    print('🎯 OTP verification completed. State: ${authProvider.state}');

    if (authProvider.state == AuthState.success) {
      print('🎯 OTP verification successful! Navigating to verification success screen...');
      // After successful OTP verification, navigate to verification success
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const VerificationSuccessScreen(),
        ),
      );
    } else {
      print('🎯 OTP verification failed. State: ${authProvider.state}');
    }
  }
}
