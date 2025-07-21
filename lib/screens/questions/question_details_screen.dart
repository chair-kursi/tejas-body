import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../models/question.dart';
import '../../models/question_dto.dart';
import '../../providers/questions_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../chat/chat_screen.dart';

class QuestionDetailsScreen extends StatefulWidget {
  final Question question;

  const QuestionDetailsScreen({
    super.key,
    required this.question,
  });

  @override
  State<QuestionDetailsScreen> createState() => _QuestionDetailsScreenState();
}

class _QuestionDetailsScreenState extends State<QuestionDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Question Details'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status and time
            _buildStatusSection(),
            const SizedBox(height: 20),
            
            // Title
            Text(
              widget.question.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            // Subject and topic
            _buildSubjectSection(),
            const SizedBox(height: 20),
            
            // Description
            _buildDescriptionSection(),
            const SizedBox(height: 20),
            
            // Image if present
            if (widget.question.imagePath != null) ...[
              _buildImageSection(),
              const SizedBox(height: 20),
            ],
            
            // Student info
            if (widget.question.student != null) ...[
              _buildStudentInfoSection(),
              const SizedBox(height: 20),
            ],
            
            // Tutor info if assigned
            if (widget.question.tutor != null) ...[
              _buildTutorInfoSection(),
              const SizedBox(height: 20),
            ],
            
            // Action buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    return Row(
      children: [
        _buildStatusChip(widget.question.status),
        const Spacer(),
        Text(
          _formatDateTime(widget.question.createdAt),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(QuestionStatus status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;
    
    switch (status) {
      case QuestionStatus.waiting:
        backgroundColor = AppColors.warning.withOpacity(0.1);
        textColor = AppColors.warning;
        icon = Icons.hourglass_empty;
        break;
      case QuestionStatus.accepted:
        backgroundColor = AppColors.success.withOpacity(0.1);
        textColor = AppColors.success;
        icon = Icons.person_add_alt_1;
        break;
      case QuestionStatus.inProgress:
      case QuestionStatus.incomplete:
        backgroundColor = AppColors.primary.withOpacity(0.1);
        textColor = AppColors.primary;
        icon = Icons.work_outline;
        break;
      case QuestionStatus.completed:
        backgroundColor = AppColors.success.withOpacity(0.1);
        textColor = AppColors.success;
        icon = Icons.check_circle_outline;
        break;
      case QuestionStatus.cancelled:
      case QuestionStatus.expired:
        backgroundColor = AppColors.error.withOpacity(0.1);
        textColor = AppColors.error;
        icon = Icons.cancel_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            status.displayName,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectSection() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.book_outlined,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                widget.question.subject,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (widget.question.topic != null) ...[
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.question.topic!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Question Description',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            widget.question.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attached Image',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image,
                  size: 48,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  'Image will be displayed here',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Image loading functionality will be implemented',
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

  Widget _buildStudentInfoSection() {
    final student = widget.question.student!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Student Information',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Academic Level', student.academicLevel),
              if (student.academicSubLevel != null)
                _buildInfoRow('Stream', student.academicSubLevel!),
              if (student.targetExam != null)
                _buildInfoRow('Target Exam', student.targetExam!),
              if (student.location != null)
                _buildInfoRow('Location', student.location!),
              _buildInfoRow('Preferred Language', student.preferredLanguage),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTutorInfoSection() {
    final tutor = widget.question.tutor!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assigned Tutor',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.success.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Teaching Experience', tutor.teachingExperience),
              _buildInfoRow('Subjects', tutor.subjects.join(', ')),
              _buildInfoRow('Class Levels', tutor.classLevelsCanTeach.join(', ')),
              _buildInfoRow('Preferred Language', tutor.preferredLanguage),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Consumer2<QuestionsProvider, AuthProvider>(
      builder: (context, questionsProvider, authProvider, child) {
        final currentUserRole = authProvider.userRole;
        final isStudent = currentUserRole == UserRole.student;
        final isTutor = currentUserRole == UserRole.tutor;

        // Different actions based on question status and user role
        if (widget.question.status == QuestionStatus.waiting) {
          if (isTutor) {
            // For tutors: Accept question button
            return CustomButton(
              text: questionsProvider.isAcceptingQuestion ? 'Accepting...' : 'Accept Question',
              isEnabled: !questionsProvider.isAcceptingQuestion,
              onPressed: () => _acceptQuestion(),
            );
          } else if (isStudent) {
            // For students: Show waiting message
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.hourglass_empty,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your question is waiting for a tutor to accept it. You will be notified once a tutor is assigned.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        } else if (widget.question.status == QuestionStatus.accepted ||
                   widget.question.status == QuestionStatus.inProgress) {
          // For accepted/in-progress questions: Chat + Status update buttons
          return Column(
            children: [
              // Chat button (always available for accepted/in-progress questions)
              CustomButton(
                text: 'Open Chat',
                icon: Icons.chat_bubble_outline,
                isEnabled: true,
                onPressed: () => _openChat(),
              ),
              if (isTutor) ...[
                const SizedBox(height: 12),
                // Status update buttons (only for tutors)
                Row(
                  children: [
                    if (widget.question.status == QuestionStatus.accepted)
                      Expanded(
                        child: CustomButton(
                          text: 'Mark as In Progress',
                          isEnabled: !questionsProvider.isUpdatingStatus,
                          onPressed: () => _updateStatus(QuestionStatus.inProgress),
                        ),
                      ),
                    if (widget.question.status == QuestionStatus.accepted)
                      const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: questionsProvider.isUpdatingStatus ? 'Updating...' : 'Mark as Completed',
                        isEnabled: !questionsProvider.isUpdatingStatus,
                        onPressed: () => _updateStatus(QuestionStatus.completed),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          );
        }
        
        // For completed or other statuses, no actions available
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.question.status == QuestionStatus.completed
                      ? 'This question has been completed.'
                      : 'No actions available for this question.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _acceptQuestion() async {
    final questionsProvider = Provider.of<QuestionsProvider>(context, listen: false);
    final success = await questionsProvider.acceptQuestion(widget.question.id);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Question accepted successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context); // Go back to previous screen
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(questionsProvider.errorMessage ?? 'Failed to accept question'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _updateStatus(QuestionStatus newStatus) async {
    final questionsProvider = Provider.of<QuestionsProvider>(context, listen: false);
    final statusDto = UpdateQuestionStatusDto(status: newStatus.value);
    
    final success = await questionsProvider.updateQuestionStatus(widget.question.id, statusDto);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Question status updated to ${newStatus.displayName}'),
            backgroundColor: AppColors.success,
          ),
        );
        // Refresh the current question data
        setState(() {
          // The question will be updated through the provider
        });
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(questionsProvider.errorMessage ?? 'Failed to update question status'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _openChat() {
    // Check if question has a tutor assigned (for accepted/in-progress questions)
    if (widget.question.tutorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This question is not assigned to any tutor yet'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Navigate to chat screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(question: widget.question),
      ),
    );
  }
}
