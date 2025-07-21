import 'package:flutter/material.dart';
import '../models/question.dart';
import '../models/question_dto.dart';
import '../services/api_service.dart';
import '../services/global_chat_service.dart';

enum QuestionsState { initial, loading, success, error }

class QuestionsProvider with ChangeNotifier {
  // State management
  QuestionsState _state = QuestionsState.initial;
  String? _errorMessage;

  // Questions data
  List<Question> _myQuestions = [];
  List<Question> _availableQuestions = [];
  Question? _selectedQuestion;

  // Loading states for different operations
  bool _isCreatingQuestion = false;
  bool _isLoadingMyQuestions = false;
  bool _isLoadingAvailableQuestions = false;
  bool _isAcceptingQuestion = false;
  bool _isUpdatingStatus = false;

  // Filters for available questions
  QuestionFiltersDto? _currentFilters;

  // Getters
  QuestionsState get state => _state;
  String? get errorMessage => _errorMessage;
  List<Question> get myQuestions => _myQuestions;
  List<Question> get availableQuestions => _availableQuestions;
  Question? get selectedQuestion => _selectedQuestion;
  bool get isCreatingQuestion => _isCreatingQuestion;
  bool get isLoadingMyQuestions => _isLoadingMyQuestions;
  bool get isLoadingAvailableQuestions => _isLoadingAvailableQuestions;
  bool get isAcceptingQuestion => _isAcceptingQuestion;
  bool get isUpdatingStatus => _isUpdatingStatus;
  QuestionFiltersDto? get currentFilters => _currentFilters;

  // Computed getters
  List<Question> get activeQuestions => _myQuestions.where((q) => q.status.isActive).toList();
  List<Question> get completedQuestions => _myQuestions.where((q) => q.status.isCompleted).toList();
  List<Question> get waitingQuestions => _myQuestions.where((q) => q.status == QuestionStatus.waiting).toList();
  
  int get totalQuestions => _myQuestions.length;
  int get activeQuestionsCount => activeQuestions.length;
  int get completedQuestionsCount => completedQuestions.length;

  // Create a new question (for students)
  Future<bool> createQuestion(CreateQuestionDto questionDto) async {
    try {
      _isCreatingQuestion = true;
      _clearError();
      notifyListeners();

      final question = await ApiService().createQuestion(questionDto);

      // Add to the beginning of my questions list
      _myQuestions.insert(0, question);

      _isCreatingQuestion = false;
      _setState(QuestionsState.success);
      return true;
    } catch (e) {
      _isCreatingQuestion = false;
      _setError('Failed to create question: ${e.toString()}');
      print('📝 QuestionsProvider: Error creating question: $e');
      return false;
    }
  }

  // Load student's questions
  Future<void> loadMyQuestions() async {
    try {
      _isLoadingMyQuestions = true;
      _clearError();
      notifyListeners();

      final questions = await ApiService().getMyQuestions();

      _myQuestions = questions;
      _isLoadingMyQuestions = false;
      _setState(QuestionsState.success);
    } catch (e) {
      _isLoadingMyQuestions = false;
      _setError('Failed to load questions: ${e.toString()}');
      print('📝 QuestionsProvider: Error loading my questions: $e');
    }
  }

  // Load available questions for tutors
  Future<void> loadAvailableQuestions({QuestionFiltersDto? filters}) async {
    try {
      _isLoadingAvailableQuestions = true;
      _clearError();
      notifyListeners();

      // Fetch available questions first
      final availableQuestions = await ApiService().getAvailableQuestions(filters: filters);

      // Fetch tutor's assignments
      final myAssignments = await ApiService().getMyAssignments();

      // Combine the lists, removing duplicates by ID
      final Map<String, Question> questionMap = {};

      // Add available questions first
      for (final question in availableQuestions) {
        questionMap[question.id] = question;
      }

      // Add assignments (this will overwrite any duplicates with the latest data)
      for (final question in myAssignments) {
        questionMap[question.id] = question;
      }

      _availableQuestions = questionMap.values.toList();
      _currentFilters = filters;
      _isLoadingAvailableQuestions = false;
      _setState(QuestionsState.success);



      // Update global chat service with new questions
      _updateGlobalChatService();
    } catch (e) {
      _isLoadingAvailableQuestions = false;
      _setError('Failed to load available questions: ${e.toString()}');
      print('📝 QuestionsProvider: Error loading available questions: $e');
    }
  }

  // Accept a question (for tutors)
  Future<bool> acceptQuestion(String questionId) async {
    try {
      _isAcceptingQuestion = true;
      _clearError();
      notifyListeners();

      print('📝 QuestionsProvider: Accepting question $questionId...');
      final updatedQuestion = await ApiService().acceptQuestion(questionId);

      // Update the question in available questions list instead of removing it
      final questionIndex = _availableQuestions.indexWhere((q) => q.id == questionId);
      if (questionIndex != -1) {
        _availableQuestions[questionIndex] = updatedQuestion;
      }

      // Also update in my questions list if it exists (for when student views their own questions)
      final myQuestionIndex = _myQuestions.indexWhere((q) => q.id == questionId);
      if (myQuestionIndex != -1) {
        _myQuestions[myQuestionIndex] = updatedQuestion;
        print('📝 QuestionsProvider: Updated question in my questions list');
      }

      // Update selected question if it matches
      if (_selectedQuestion?.id == questionId) {
        _selectedQuestion = updatedQuestion;
      }

      _isAcceptingQuestion = false;
      _setState(QuestionsState.success);

      print('📝 QuestionsProvider: Question accepted successfully');
      return true;
    } catch (e) {
      _isAcceptingQuestion = false;
      _setError('Failed to accept question: ${e.toString()}');
      print('📝 QuestionsProvider: Error accepting question: $e');
      return false;
    }
  }

  // Update question status
  Future<bool> updateQuestionStatus(String questionId, UpdateQuestionStatusDto statusDto) async {
    try {
      _isUpdatingStatus = true;
      _clearError();
      notifyListeners();

      print('📝 QuestionsProvider: Updating question status...');
      final updatedQuestion = await ApiService().updateQuestionStatus(questionId, statusDto);
      
      // Update in my questions list
      final index = _myQuestions.indexWhere((q) => q.id == questionId);
      if (index != -1) {
        _myQuestions[index] = updatedQuestion;
      }
      
      // Update selected question if it matches
      if (_selectedQuestion?.id == questionId) {
        _selectedQuestion = updatedQuestion;
      }
      
      _isUpdatingStatus = false;
      _setState(QuestionsState.success);
      
      print('📝 QuestionsProvider: Question status updated successfully');
      return true;
    } catch (e) {
      _isUpdatingStatus = false;
      _setError('Failed to update question status: ${e.toString()}');
      print('📝 QuestionsProvider: Error updating question status: $e');
      return false;
    }
  }

  // Load question details
  Future<void> loadQuestionDetails(String questionId) async {
    try {
      _clearError();
      notifyListeners();

      print('📝 QuestionsProvider: Loading question details...');
      final question = await ApiService().getQuestionById(questionId);
      
      _selectedQuestion = question;
      _setState(QuestionsState.success);
      
      print('📝 QuestionsProvider: Question details loaded successfully');
    } catch (e) {
      _setError('Failed to load question details: ${e.toString()}');
      print('📝 QuestionsProvider: Error loading question details: $e');
    }
  }

  // Set selected question
  void setSelectedQuestion(Question? question) {
    _selectedQuestion = question;
    notifyListeners();
  }

  // Clear selected question
  void clearSelectedQuestion() {
    _selectedQuestion = null;
    notifyListeners();
  }

  // Refresh data
  Future<void> refreshMyQuestions() async {
    await loadMyQuestions();
  }

  Future<void> refreshAvailableQuestions() async {
    await loadAvailableQuestions(filters: _currentFilters);
  }

  // Refresh a specific question by ID (useful for real-time updates)
  Future<void> refreshQuestionById(String questionId) async {
    try {
      print('📝 QuestionsProvider: Refreshing question $questionId...');
      final updatedQuestion = await ApiService().getQuestionById(questionId);

      // Update in my questions list
      final myQuestionIndex = _myQuestions.indexWhere((q) => q.id == questionId);
      if (myQuestionIndex != -1) {
        _myQuestions[myQuestionIndex] = updatedQuestion;
        print('📝 QuestionsProvider: Updated question in my questions list');
      }

      // Update in available questions list
      final availableQuestionIndex = _availableQuestions.indexWhere((q) => q.id == questionId);
      if (availableQuestionIndex != -1) {
        _availableQuestions[availableQuestionIndex] = updatedQuestion;
        print('📝 QuestionsProvider: Updated question in available questions list');
      }

      // Update selected question if it matches
      if (_selectedQuestion?.id == questionId) {
        _selectedQuestion = updatedQuestion;
      }

      notifyListeners();
      print('📝 QuestionsProvider: Question refreshed successfully');
    } catch (e) {
      print('📝 QuestionsProvider: Error refreshing question: $e');
      // Don't show error to user for background refresh
    }
  }

  // Clear all data
  void clearAllData() {
    _myQuestions.clear();
    _availableQuestions.clear();
    _selectedQuestion = null;
    _currentFilters = null;
    _setState(QuestionsState.initial);
  }

  // Private helper methods
  void _setState(QuestionsState newState) {
    _state = newState;
    if (newState != QuestionsState.error) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _setState(QuestionsState.error);
  }

  void _clearError() {
    _errorMessage = null;
    if (_state == QuestionsState.error) {
      _state = QuestionsState.initial;
    }
  }

  // Get questions by status
  List<Question> getQuestionsByStatus(QuestionStatus status) {
    return _myQuestions.where((q) => q.status == status).toList();
  }

  // Get questions by subject
  List<Question> getQuestionsBySubject(String subject) {
    return _myQuestions.where((q) => q.subject == subject).toList();
  }

  // Search questions
  List<Question> searchQuestions(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _myQuestions.where((q) =>
      q.title.toLowerCase().contains(lowercaseQuery) ||
      q.description.toLowerCase().contains(lowercaseQuery) ||
      q.subject.toLowerCase().contains(lowercaseQuery) ||
      (q.topic?.toLowerCase().contains(lowercaseQuery) ?? false)
    ).toList();
  }

  // Update global chat service with current questions
  void _updateGlobalChatService() {
    try {
      final allQuestions = [..._myQuestions, ..._availableQuestions];
      GlobalChatService().updateActiveQuestions(allQuestions);
    } catch (e) {
      print('📝 QuestionsProvider: Error updating global chat service: $e');
    }
  }

  // Computed getter for assignments (accepted questions)
  List<Question> get myAssignments => _availableQuestions.where((q) => q.status == QuestionStatus.accepted).toList();
}
