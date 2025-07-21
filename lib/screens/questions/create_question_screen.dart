import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../models/question_dto.dart';
import '../../providers/questions_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class CreateQuestionScreen extends StatefulWidget {
  const CreateQuestionScreen({super.key});

  @override
  State<CreateQuestionScreen> createState() => _CreateQuestionScreenState();
}

class _CreateQuestionScreenState extends State<CreateQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String? _selectedSubject;
  String? _selectedTopic;
  File? _selectedImage;
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
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
        title: const Text('Ask a Question'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: Consumer<QuestionsProvider>(
          builder: (context, questionsProvider, child) {
            return Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppConstants.defaultPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Text(
                            'What do you need help with?',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Provide as much detail as possible to get the best help from our tutors.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Question Title
                          CustomTextField(
                            controller: _titleController,
                            labelText: 'Question Title',
                            hintText: 'Enter a clear, specific title for your question',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a question title';
                              }
                              if (value.trim().length < 10) {
                                return 'Title should be at least 10 characters long';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Subject Selection
                          _buildSubjectDropdown(),
                          const SizedBox(height: 20),

                          // Topic Selection (if subject is selected)
                          if (_selectedSubject != null) ...[
                            _buildTopicDropdown(),
                            const SizedBox(height: 20),
                          ],

                          // Question Description
                          CustomTextField(
                            controller: _descriptionController,
                            labelText: 'Question Description',
                            hintText: 'Describe your question in detail. Include what you\'ve tried and where you\'re stuck.',
                            maxLines: 6,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a question description';
                              }
                              if (value.trim().length < 20) {
                                return 'Description should be at least 20 characters long';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Image Upload Section
                          _buildImageUploadSection(),
                          const SizedBox(height: 32),

                          // Tips Section
                          _buildTipsSection(),
                        ],
                      ),
                    ),
                  ),

                  // Submit Button
                  Padding(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    child: CustomButton(
                      text: questionsProvider.isCreatingQuestion ? 'Submitting...' : 'Submit Question',
                      isEnabled: !questionsProvider.isCreatingQuestion && _canSubmit(),
                      onPressed: _submitQuestion,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSubjectDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subject *',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
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
              value: _selectedSubject,
              hint: const Text('Select a subject'),
              isExpanded: true,
              items: QuestionSubjects.allSubjects.map((subject) {
                return DropdownMenuItem<String>(
                  value: subject,
                  child: Text(subject),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSubject = value;
                  _selectedTopic = null; // Reset topic when subject changes
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopicDropdown() {
    final topics = QuestionSubjects.getTopicsForSubject(_selectedSubject!);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Topic (Optional)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
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
              value: _selectedTopic,
              hint: const Text('Select a topic (optional)'),
              isExpanded: true,
              items: topics.map((topic) {
                return DropdownMenuItem<String>(
                  value: topic,
                  child: Text(topic),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTopic = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add Image (Optional)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(
                color: _selectedImage != null ? AppColors.success : AppColors.border,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
              color: AppColors.backgroundSecondary,
            ),
            child: _selectedImage != null
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _selectedImage!,
                          width: double.infinity,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedImage = null),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
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
                        'Tap to upload an image (Optional)',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'You can submit without an image',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('You can submit your question without an image'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                        child: Text(
                          'Continue without image',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildTipsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Tips for better help',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '• Be specific about what you\'re struggling with\n'
            '• Include any work you\'ve already done\n'
            '• Mention your grade level or course\n'
            '• Add images of problems or diagrams if helpful',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  bool _canSubmit() {
    return _titleController.text.trim().isNotEmpty &&
           _descriptionController.text.trim().isNotEmpty &&
           _selectedSubject != null;
  }

  void _pickImage() {
    // For now, show a dialog to simulate image selection
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Image'),
          content: const Text('Image picker functionality will be implemented later. For now, you can skip adding an image and submit your question.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                // Simulate selecting a dummy image for testing
                setState(() {
                  _selectedImage = null; // Keep as null since we don't have real image picker
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('You can submit your question without an image for now'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              child: const Text('Skip Image'),
            ),
          ],
        );
      },
    );
  }

  void _submitQuestion() async {
    if (!_formKey.currentState!.validate()) return;

    final questionDto = CreateQuestionDto(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      subject: _selectedSubject!,
      topic: _selectedTopic,
      image: _selectedImage,
    );

    final questionsProvider = Provider.of<QuestionsProvider>(context, listen: false);
    final success = await questionsProvider.createQuestion(questionDto);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Question submitted successfully! A tutor will help you soon.'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(questionsProvider.errorMessage ?? 'Failed to submit question'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
