import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/tutor_onboarding_provider.dart';
import '../../widgets/custom_button.dart';
import 'tutor_test_screen.dart';

class DocumentUploadScreen extends StatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  String? _profilePhotoPath;
  String? _idProofPath;
  String? _qualificationCertificatePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Document upload'),
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
                        'Kindly upload the necessary\ndocuments',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      const SizedBox(height: 40),
                      
                      // Profile Photo Upload
                      _buildUploadSection(
                        title: 'Upload Profile Photo',
                        filePath: _profilePhotoPath,
                        onTap: () => _showImagePickerOptions('profile'),
                      ),
                      const SizedBox(height: 24),
                      
                      // ID Proof Upload
                      _buildUploadSection(
                        title: 'Upload ID Proof',
                        filePath: _idProofPath,
                        onTap: () => _showFilePickerOptions('id'),
                      ),
                      const SizedBox(height: 24),

                      // Qualification Certificate Upload
                      _buildUploadSection(
                        title: 'Upload Qualification Certificate',
                        filePath: _qualificationCertificatePath,
                        onTap: () => _showFilePickerOptions('qualification'),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Continue button (temporarily allow skipping file uploads for testing)
              CustomButton(
                text: 'Continue (Skip for now)',
                isEnabled: true, // Always enabled for testing
                onPressed: () {
                  final provider = Provider.of<TutorOnboardingProvider>(context, listen: false);
                  // Set dummy paths for testing if no files uploaded
                  provider.setProfilePhoto(_profilePhotoPath ?? 'dummy_profile_photo.jpg');
                  provider.setIdProof(_idProofPath ?? 'dummy_id_proof.jpg');
                  provider.setQualificationCertificate(_qualificationCertificatePath ?? 'dummy_qualification.jpg');

                  print('🎓 Document upload screen - continuing with dummy files for testing');

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TutorTestScreen(),
                    ),
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

  Widget _buildUploadSection({
    required String title,
    required String? filePath,
    required VoidCallback onTap,
  }) {
    final bool hasFile = filePath != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(
                color: hasFile ? AppColors.success : AppColors.border,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(12),
              color: AppColors.backgroundSecondary,
            ),
            child: hasFile
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 32,
                        color: AppColors.success,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'File Uploaded',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap to change',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 32,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Click to Upload',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '(Max. File size: 25 MB)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  void _showImagePickerOptions(String type) {
    // TODO: Implement image picker when needed
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Image picker functionality will be implemented later'),
      ),
    );
  }

  void _showFilePickerOptions(String type) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(type);
                },
              ),
              ListTile(
                leading: const Icon(Icons.folder),
                title: const Text('Choose File'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickFile(type);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(String type) async {
    // TODO: Implement image picker when needed
    setState(() {
      if (type == 'profile') {
        _profilePhotoPath = 'mock_profile_photo.jpg';
      } else if (type == 'id') {
        _idProofPath = 'mock_id_proof.jpg';
      } else if (type == 'qualification') {
        _qualificationCertificatePath = 'mock_qualification.jpg';
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Mock $type file selected')),
    );
  }

  Future<void> _pickFile(String type) async {
    // TODO: Implement file picker when needed
    setState(() {
      if (type == 'id') {
        _idProofPath = 'mock_id_proof.pdf';
      } else if (type == 'qualification') {
        _qualificationCertificatePath = 'mock_qualification.pdf';
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Mock $type file selected')),
    );
  }
}
