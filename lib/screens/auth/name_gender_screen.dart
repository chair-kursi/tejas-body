import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_overlay.dart';
import 'role_selection_screen.dart';

class NameGenderScreen extends StatefulWidget {
  const NameGenderScreen({super.key});

  @override
  State<NameGenderScreen> createState() => _NameGenderScreenState();
}

class _NameGenderScreenState extends State<NameGenderScreen> {
  final TextEditingController _nameController = TextEditingController();
  Gender? _selectedGender;

  @override
  void dispose() {
    _nameController.dispose();
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
          'Name & gender',
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
                              child: const Center(
                                child: Icon(
                                  Icons.person_outline,
                                  size: 80,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            
                            // Title
                            Text(
                              'Let\'s Get to Know You Better !',
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                            const SizedBox(height: 32),
                            
                            // Name input
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                hintText: 'Enter Your Full Name',
                              ),
                              onChanged: (value) {
                                setState(() {});
                              },
                            ),
                            const SizedBox(height: 32),
                            
                            // Gender selection
                            Text(
                              'Please select your gender identity',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            
                            ...Gender.values.map((gender) => _buildGenderOption(gender, authProvider)),
                            
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
                      isEnabled: _isFormValid(),
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

  Widget _buildGenderOption(Gender gender, AuthProvider authProvider) {
    final isSelected = _selectedGender == gender;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedGender = gender;
          });
        },
        child: Row(
          children: [
            Radio<Gender>(
              value: gender,
              groupValue: _selectedGender,
              onChanged: (Gender? value) {
                setState(() {
                  _selectedGender = value;
                });
              },
              activeColor: AppColors.primary,
            ),
            const SizedBox(width: 12),
            Text(
              authProvider.getGenderDisplayName(gender),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isFormValid() {
    return _nameController.text.trim().length >= AppConstants.minNameLength &&
           _nameController.text.trim().length <= AppConstants.maxNameLength &&
           _selectedGender != null;
  }

  void _handleContinue(AuthProvider authProvider) {
    if (_isFormValid() && _selectedGender != null) {
      authProvider.setUserDetails(_nameController.text.trim(), _selectedGender!);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const RoleSelectionScreen(),
        ),
      );
    }
  }
}
