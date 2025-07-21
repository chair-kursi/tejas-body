import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../models/question.dart';
import '../../models/question_dto.dart';
import '../../providers/questions_provider.dart';
import '../../widgets/custom_button.dart';
import '../chat/chat_screen.dart';
import '../../services/global_chat_service.dart';
import '../../services/notification_service.dart';

class AvailableQuestionsScreen extends StatefulWidget {
  const AvailableQuestionsScreen({super.key});

  @override
  State<AvailableQuestionsScreen> createState() => _AvailableQuestionsScreenState();
}

class _AvailableQuestionsScreenState extends State<AvailableQuestionsScreen> {
  String? _selectedSubjectFilter;
  
  @override
  void initState() {
    super.initState();

    print('🎯 AvailableQuestionsScreen: initState() called');

    // Load available questions when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🎯 AvailableQuestionsScreen: Loading available questions...');
      Provider.of<QuestionsProvider>(context, listen: false).loadAvailableQuestions();

      // Initialize global chat service
      _initializeGlobalChatService();
    });
  }

  void _initializeGlobalChatService() {
    final questionsProvider = Provider.of<QuestionsProvider>(context, listen: false);
    final globalChatService = Provider.of<GlobalChatService>(context, listen: false);

    // Initialize with current questions
    final allQuestions = [
      ...questionsProvider.availableQuestions,
      ...questionsProvider.myAssignments,
    ];

    globalChatService.initialize(allQuestions);

    // Set up new message callback
    globalChatService.addNewMessageCallback((questionId, message) {
      // Find the question
      final question = allQuestions.firstWhere(
        (q) => q.id == questionId,
        orElse: () => Question(
          id: questionId,
          title: 'Unknown Question',
          description: '',
          subject: '',
          topic: '',
          status: QuestionStatus.accepted,
          studentId: '',
          tutorId: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      // Show notification if we're not on the chat screen for this question
      if (mounted) {
        NotificationService.showNewMessageNotification(
          context,
          questionId,
          message,
          question,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('🎯 AvailableQuestionsScreen: build() called');
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Available Questions'),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<QuestionsProvider>(context, listen: false).refreshAvailableQuestions();
            },
          ),
        ],
      ),
      body: Consumer<QuestionsProvider>(
        builder: (context, questionsProvider, child) {
          if (questionsProvider.isLoadingAvailableQuestions) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (questionsProvider.state == QuestionsState.error) {
            return _buildErrorState(questionsProvider.errorMessage);
          }

          final questions = questionsProvider.availableQuestions;

          if (questions.isEmpty) {
            return _buildEmptyState();
          }

          // Separate questions by status (using enum values)
          final waitingQuestions = questions.where((q) => q.status == QuestionStatus.waiting).toList();
          final acceptedQuestions = questions.where((q) => q.status == QuestionStatus.accepted).toList();
          final incompleteQuestions = questions.where((q) => q.status == QuestionStatus.inProgress).toList();

          print('🎯 DEBUG: Total questions: ${questions.length}');
          print('🎯 DEBUG: Waiting questions: ${waitingQuestions.length}');
          print('🎯 DEBUG: Accepted questions: ${acceptedQuestions.length}');
          print('🎯 DEBUG: Incomplete questions: ${incompleteQuestions.length}');
          for (var q in questions) {
            print('🎯 DEBUG: Question ${q.id} has status: "${q.status}"');
          }

          return Column(
            children: [
              // Filter indicator
              if (_selectedSubjectFilter != null)
                _buildFilterIndicator(),

              // Questions list with sections
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await Provider.of<QuestionsProvider>(context, listen: false)
                        .refreshAvailableQuestions();
                  },
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Waiting Questions Section
                        if (waitingQuestions.isNotEmpty) ...[
                          _buildSectionHeader('Available Questions', waitingQuestions.length, Icons.assignment_turned_in, AppColors.success),
                          const SizedBox(height: 12),
                          ...waitingQuestions.map((question) => _buildQuestionCard(question)),
                          const SizedBox(height: 24),
                        ],

                        // Accepted Questions Section
                        if (acceptedQuestions.isNotEmpty) ...[
                          _buildSectionHeader('My Accepted Questions', acceptedQuestions.length, Icons.person_add_alt_1, AppColors.primary),
                          const SizedBox(height: 12),
                          ...acceptedQuestions.map((question) => _buildAcceptedQuestionCard(question)),
                          const SizedBox(height: 24),
                        ],

                        // Incomplete Questions Section
                        if (incompleteQuestions.isNotEmpty) ...[
                          _buildSectionHeader('In Progress Questions', incompleteQuestions.length, Icons.hourglass_empty, AppColors.warning),
                          const SizedBox(height: 12),
                          ...incompleteQuestions.map((question) => _buildIncompleteQuestionCard(question)),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_list,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'Filtered by: $_selectedSubjectFilter',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _clearFilters,
            child: Icon(
              Icons.close,
              size: 16,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: color,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Question question) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and time
            Row(
              children: [
                Expanded(
                  child: Text(
                    question.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDateTime(question.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Subject and topic
            Row(
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      question.subject,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                if (question.topic != null) ...[
                  const SizedBox(width: 8),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        question.topic!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            
            // Description
            Text(
              question.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            
            // Student info and action button
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Student: ${question.student?.academicLevel ?? 'Unknown'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Consumer<QuestionsProvider>(
                  builder: (context, questionsProvider, child) {
                    return SizedBox(
                      width: 160, // Fixed width for the button
                      child: CustomButton(
                        text: questionsProvider.isAcceptingQuestion ? 'Accepting...' : 'Accept Question',
                        isEnabled: !questionsProvider.isAcceptingQuestion,
                        onPressed: () => _acceptQuestion(question.id),
                      ),
                    );
                  },
                ),
              ],
            ),
            
            // Image indicator if present
            if (question.imagePath != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.image,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Contains image',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIncompleteQuestionCard(Question question) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.warning.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.hourglass_empty,
                        size: 12,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'In Progress',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDateTime(question.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Question title
            Text(
              question.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            // Question description
            Text(
              question.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // Subject and topic
            Row(
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      question.subject,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      question.topic ?? '',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.info,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Student info
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${question.student?.academicLevel ?? 'N/A'} • ${question.student?.academicSubLevel ?? 'N/A'} • ${question.student?.location ?? 'N/A'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Bottom row with info message and chat button
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This question is currently being worked on by a tutor',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _openChatForQuestion(question),
                  icon: const Icon(Icons.chat_bubble_outline, size: 16),
                  label: const Text('Chat'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),

            // Image indicator if present
            if (question.imagePath != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.image,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Contains image',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAcceptedQuestionCard(Question question) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.primary.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person_add_alt_1,
                        size: 12,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Accepted',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDateTime(question.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Question title
            Text(
              question.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            // Question description
            Text(
              question.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // Subject and topic
            Row(
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      question.subject,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      question.topic ?? '',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.info,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Student info
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${question.student?.academicLevel ?? 'N/A'} • ${question.student?.academicSubLevel ?? 'N/A'} • ${question.student?.location ?? 'N/A'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Bottom row with action buttons
            Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 16,
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You have accepted this question. Start working on it!',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _openChatForQuestion(question),
                  icon: const Icon(Icons.chat_bubble_outline, size: 16),
                  label: const Text('Chat'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),

            // Image indicator if present
            if (question.imagePath != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.image,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Contains image',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No questions available',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedSubjectFilter != null
                  ? 'No questions found for $_selectedSubjectFilter. Try adjusting your filters.'
                  : 'There are no questions waiting for help right now. Check back later!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            if (_selectedSubjectFilter != null)
              CustomButton(
                text: 'Clear Filters',
                isEnabled: true,
                onPressed: _clearFilters,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String? errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? 'Failed to load available questions',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Try Again',
              isEnabled: true,
              onPressed: () {
                Provider.of<QuestionsProvider>(context, listen: false).loadAvailableQuestions();
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    // Use local device time for accurate "time ago" calculation
    final now = DateTime.now();
    final questionTime = dateTime.toLocal(); // Convert UTC to local time
    final difference = now.difference(questionTime);

    print('🎯 Time debug - Now (local): $now, Question (local): $questionTime, Difference: ${difference.inMinutes} minutes');

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter Questions'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Filter by subject:'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedSubjectFilter,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('All Subjects'),
                  ),
                  ...QuestionSubjects.allSubjects.map((subject) {
                    return DropdownMenuItem<String>(
                      value: subject,
                      child: Text(subject),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedSubjectFilter = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _applyFilters();
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  void _applyFilters() {
    final filters = QuestionFiltersDto(
      subjects: _selectedSubjectFilter != null ? [_selectedSubjectFilter!] : null,
    );
    
    Provider.of<QuestionsProvider>(context, listen: false)
        .loadAvailableQuestions(filters: filters);
  }

  void _clearFilters() {
    setState(() {
      _selectedSubjectFilter = null;
    });
    
    Provider.of<QuestionsProvider>(context, listen: false)
        .loadAvailableQuestions();
  }

  void _acceptQuestion(String questionId) async {
    print('🎯 AvailableQuestionsScreen: _acceptQuestion called for question: $questionId');

    final questionsProvider = Provider.of<QuestionsProvider>(context, listen: false);
    print('🎯 AvailableQuestionsScreen: Calling questionsProvider.acceptQuestion...');

    final success = await questionsProvider.acceptQuestion(questionId);
    print('🎯 AvailableQuestionsScreen: Accept question result: $success');

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Question accepted successfully! You can now help the student.'),
            backgroundColor: AppColors.success,
          ),
        );
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

  void _openChatForQuestion(Question question) {
    // Check if question has a tutor assigned
    if (question.tutorId == null) {
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
        builder: (context) => ChatScreen(question: question),
      ),
    );
  }
}
