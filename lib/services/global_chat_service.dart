import 'dart:async';
import 'package:flutter/material.dart';
import '../models/message.dart';
import '../models/question.dart';
import '../services/api_service.dart';

class GlobalChatService extends ChangeNotifier {
  static final GlobalChatService _instance = GlobalChatService._internal();
  factory GlobalChatService() => _instance;
  GlobalChatService._internal();

  // Service state
  Timer? _globalPollingTimer;
  bool _isPollingActive = false;
  static const Duration _pollingInterval = Duration(seconds: 5);
  
  // Chat data
  Map<String, List<Message>> _allMessages = {};
  Map<String, int> _lastMessageCounts = {};
  List<Question> _activeQuestions = [];
  
  // Notification callbacks
  final List<Function(String questionId, Message message)> _newMessageCallbacks = [];
  
  // Getters
  bool get isPollingActive => _isPollingActive;
  Map<String, List<Message>> get allMessages => _allMessages;
  List<Question> get activeQuestions => _activeQuestions;
  
  // Get unread message count for a question
  int getUnreadCount(String questionId) {
    final currentCount = _allMessages[questionId]?.length ?? 0;
    final lastKnownCount = _lastMessageCounts[questionId] ?? 0;
    return currentCount > lastKnownCount ? currentCount - lastKnownCount : 0;
  }
  
  // Mark messages as read for a question
  void markAsRead(String questionId) {
    final currentCount = _allMessages[questionId]?.length ?? 0;
    _lastMessageCounts[questionId] = currentCount;
    notifyListeners();
  }
  
  // Get total unread count across all questions
  int getTotalUnreadCount() {
    int total = 0;
    for (String questionId in _allMessages.keys) {
      total += getUnreadCount(questionId);
    }
    return total;
  }
  
  // Add callback for new message notifications
  void addNewMessageCallback(Function(String questionId, Message message) callback) {
    _newMessageCallbacks.add(callback);
  }
  
  // Remove callback
  void removeNewMessageCallback(Function(String questionId, Message message) callback) {
    _newMessageCallbacks.remove(callback);
  }
  
  // Initialize the service with active questions
  Future<void> initialize(List<Question> questions) async {
    print('🌐 GlobalChatService: Initializing with ${questions.length} questions');
    _activeQuestions = questions.where((q) => q.status == QuestionStatus.accepted).toList();
    
    // Load initial message counts
    for (Question question in _activeQuestions) {
      try {
        final messages = await ApiService().getMessages(question.id);
        _allMessages[question.id] = messages;
        _lastMessageCounts[question.id] = messages.length;
      } catch (e) {
        print('🌐 GlobalChatService: Error loading initial messages for ${question.id}: $e');
      }
    }
    
    startGlobalPolling();
    notifyListeners();
  }
  
  // Start global polling for all active questions
  void startGlobalPolling() {
    if (_isPollingActive) return;
    
    print('🌐 GlobalChatService: Starting global polling');
    _isPollingActive = true;
    
    _globalPollingTimer?.cancel();
    _globalPollingTimer = Timer.periodic(_pollingInterval, (timer) {
      if (_isPollingActive) {
        _pollAllQuestions();
      }
    });
  }
  
  // Stop global polling
  void stopGlobalPolling() {
    print('🌐 GlobalChatService: Stopping global polling');
    _isPollingActive = false;
    _globalPollingTimer?.cancel();
    _globalPollingTimer = null;
  }
  
  // Poll all active questions for new messages
  Future<void> _pollAllQuestions() async {
    if (_activeQuestions.isEmpty) return;
    
    print('🌐 GlobalChatService: Polling ${_activeQuestions.length} questions for new messages');
    
    for (Question question in _activeQuestions) {
      try {
        await _pollQuestion(question.id);
      } catch (e) {
        print('🌐 GlobalChatService: Error polling question ${question.id}: $e');
      }
    }
  }
  
  // Poll a specific question for new messages
  Future<void> _pollQuestion(String questionId) async {
    try {
      final messages = await ApiService().getMessages(questionId);
      final previousMessages = _allMessages[questionId] ?? [];
      
      if (messages.length > previousMessages.length) {
        // New messages found
        final newMessages = messages.sublist(previousMessages.length);
        print('🌐 GlobalChatService: Found ${newMessages.length} new messages for question $questionId');
        
        _allMessages[questionId] = messages;
        
        // Notify callbacks about new messages
        for (Message newMessage in newMessages) {
          for (var callback in _newMessageCallbacks) {
            try {
              callback(questionId, newMessage);
            } catch (e) {
              print('🌐 GlobalChatService: Error in callback: $e');
            }
          }
        }
        
        notifyListeners();
      } else if (messages.length != previousMessages.length) {
        // Message count changed (could be deletion or other changes)
        _allMessages[questionId] = messages;
        notifyListeners();
      }
    } catch (e) {
      print('🌐 GlobalChatService: Error polling question $questionId: $e');
    }
  }
  
  // Update active questions (call when questions list changes)
  void updateActiveQuestions(List<Question> questions) {
    final newActiveQuestions = questions.where((q) => q.status == QuestionStatus.accepted).toList();
    
    // Check if the list has changed
    if (_activeQuestions.length != newActiveQuestions.length ||
        !_activeQuestions.every((q) => newActiveQuestions.any((nq) => nq.id == q.id))) {
      
      print('🌐 GlobalChatService: Updating active questions from ${_activeQuestions.length} to ${newActiveQuestions.length}');
      _activeQuestions = newActiveQuestions;
      
      // Initialize message counts for new questions
      for (Question question in newActiveQuestions) {
        if (!_allMessages.containsKey(question.id)) {
          _loadInitialMessages(question.id);
        }
      }
      
      // Clean up old questions
      final activeIds = newActiveQuestions.map((q) => q.id).toSet();
      _allMessages.removeWhere((key, value) => !activeIds.contains(key));
      _lastMessageCounts.removeWhere((key, value) => !activeIds.contains(key));
      
      notifyListeners();
    }
  }
  
  // Load initial messages for a question
  Future<void> _loadInitialMessages(String questionId) async {
    try {
      final messages = await ApiService().getMessages(questionId);
      _allMessages[questionId] = messages;
      _lastMessageCounts[questionId] = messages.length;
    } catch (e) {
      print('🌐 GlobalChatService: Error loading initial messages for $questionId: $e');
    }
  }
  
  // Get messages for a specific question
  List<Message> getMessagesForQuestion(String questionId) {
    return _allMessages[questionId] ?? [];
  }
  
  // Add a message locally (for optimistic updates)
  void addMessageLocally(String questionId, Message message) {
    if (_allMessages[questionId] != null) {
      _allMessages[questionId]!.add(message);
    } else {
      _allMessages[questionId] = [message];
    }
    notifyListeners();
  }
  
  // Pause polling (useful when app goes to background)
  void pausePolling() {
    print('🌐 GlobalChatService: Pausing polling');
    _isPollingActive = false;
  }
  
  // Resume polling (useful when app comes to foreground)
  void resumePolling() {
    if (_globalPollingTimer != null && !_isPollingActive) {
      print('🌐 GlobalChatService: Resuming polling');
      _isPollingActive = true;
    }
  }
  
  @override
  void dispose() {
    stopGlobalPolling();
    _newMessageCallbacks.clear();
    _allMessages.clear();
    _lastMessageCounts.clear();
    _activeQuestions.clear();
    super.dispose();
  }
}
