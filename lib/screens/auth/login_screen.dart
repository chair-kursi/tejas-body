import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:country_picker/country_picker.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../services/storage_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_overlay.dart';
import '../onboarding/language_selection_screen.dart';
import '../tutor_onboarding/tutor_language_selection_screen.dart';
import 'otp_verification_screen.dart';
import 'name_gender_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool isLogin;
  
  const LoginScreen({super.key, this.isLogin = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  Country _selectedCountry = Country.parse('IN');
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Set the mode in auth provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().setRegistrationMode(!widget.isLogin);
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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
          widget.isLogin ? 'Login page' : 'Signup Screen',
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            
                            // Illustration
                            Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.backgroundSecondary,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Icon(
                                  widget.isLogin ? Icons.login_outlined : Icons.person_add_outlined,
                                  size: 80,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            
                            // Title
                            Text(
                              widget.isLogin ? 'Log in' : 'Sign up',
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                            const SizedBox(height: 32),
                            
                            if (widget.isLogin) ...[
                              // Login form
                              _buildLoginForm(authProvider),
                            ] else ...[
                              // Signup form
                              _buildSignupForm(authProvider),
                            ],
                            
                            if (authProvider.errorMessage != null) ...[
                              const SizedBox(height: 16),
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
                    
                    // Continue button
                    CustomButton(
                      text: 'Continue',
                      isEnabled: _isFormValid(authProvider),
                      onPressed: () => _handleContinue(authProvider),
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

  Widget _buildSignupForm(AuthProvider authProvider) {
    return Column(
      children: [
        // Country code and phone number
        Row(
          children: [
            // Country picker
            GestureDetector(
              onTap: _showCountryPicker,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedCountry.flagEmoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '+${_selectedCountry.phoneCode}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Phone number input
            Expanded(
              child: TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: 'Enter mobile number',
                ),
                onChanged: (value) {
                  authProvider.setPhoneNumber(value, '+${_selectedCountry.phoneCode}');
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Email input
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'Enter email address',
            prefixIcon: Icon(Icons.email_outlined),
          ),
          onChanged: (value) {
            authProvider.setEmail(value);
          },
        ),
        const SizedBox(height: 16),

        // Password input
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: 'Enter password',
            prefixIcon: const Icon(Icons.lock_outlined),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          onChanged: (value) {
            authProvider.setPassword(value);
          },
        ),
      ],
    );
  }

  Widget _buildLoginForm(AuthProvider authProvider) {
    return Column(
      children: [
        // Email input
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'Enter email address',
            prefixIcon: Icon(Icons.email_outlined),
          ),
          onChanged: (value) {
            authProvider.setEmail(value);
          },
        ),
        const SizedBox(height: 16),

        // Password input
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: 'Enter password',
            prefixIcon: const Icon(Icons.lock_outlined),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          onChanged: (value) {
            authProvider.setPassword(value);
          },
        ),

        // Country code selector for login
        Row(
          children: [
            GestureDetector(
              onTap: _showCountryPicker,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedCountry.flagEmoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '+${_selectedCountry.phoneCode}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Text(
                'Selected country: ${_selectedCountry.name}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showCountryPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (Country country) {
        setState(() {
          _selectedCountry = country;
        });
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        authProvider.setPhoneNumber(_phoneController.text, '+${country.phoneCode}');
      },
    );
  }

  bool _isFormValid(AuthProvider authProvider) {
    if (widget.isLogin) {
      return authProvider.canLogin;
    } else {
      return authProvider.canProceedWithRegistrationData;
    }
  }

  void _handleContinue(AuthProvider authProvider) async {
    if (widget.isLogin) {
      // For login, call login API directly
      await authProvider.login();
      if (authProvider.state == AuthState.success) {
        // Check if onboarding is complete
        final isOnboardingComplete = StorageService.isOnboardingComplete();

        if (isOnboardingComplete) {
          // User has completed onboarding, go to main app
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false,
          );
        } else {
          // User needs to complete onboarding, navigate to appropriate flow
          if (authProvider.userRole == UserRole.student) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LanguageSelectionScreen()),
              (route) => false,
            );
          } else if (authProvider.userRole == UserRole.tutor) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const TutorLanguageSelectionScreen()),
              (route) => false,
            );
          } else {
            // Fallback to home if role is not determined
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
            );
          }
        }
      }
    } else {
      // For signup, continue to name & gender screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const NameGenderScreen(),
        ),
      );
    }
  }
}
