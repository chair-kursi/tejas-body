import 'dart:async';
import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/api_service.dart';

enum ChatState { initial, loading, success, error }

class ChatProvider with ChangeNotifier {
  // State management
  ChatState _state = ChatState.initial;
  String? _errorMessage;

  // Chat data
  Map<String, List<Message>> _messagesByQuestion = {};
  bool _isSendingMessage = false;
  bool _isLoadingMessages = false;

  // Real-time polling
  Timer? _pollingTimer;
  String? _activeQuestionId;
  static const Duration _pollingInterval = Duration(seconds: 3);
  bool _isPollingEnabled = false;

  // Getters
  ChatState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isSendingMessage => _isSendingMessage;
  bool get isLoadingMessages => _isLoadingMessages;
  bool get isPollingEnabled => _isPollingEnabled;
  String? get activeQuestionId => _activeQuestionId;

  // Get messages for a specific question
  List<Message> getMessagesForQuestion(String questionId) {
    return _messagesByQuestion[questionId] ?? [];
  }

  // Check if messages are loaded for a question
  bool hasMessagesLoaded(String questionId) {
    return _messagesByQuestion.containsKey(questionId);
  }

  // Get message count for a question
  int getMessageCount(String questionId) {
    return _messagesByQuestion[questionId]?.length ?? 0;
  }

  // Private methods
  void _setState(ChatState state) {
    _state = state;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _setState(ChatState.error);
  }

  void _clearError() {
    _errorMessage = null;
  }

  // Load messages for a question
  Future<void> loadMessages(String questionId) async {
    try {
      _isLoadingMessages = true;
      _clearError();
      notifyListeners();

      final messages = await ApiService().getMessages(questionId);

      _messagesByQuestion[questionId] = messages;
      _isLoadingMessages = false;
      _setState(ChatState.success);
    } catch (e) {
      _isLoadingMessages = false;
      _setError('Failed to load messages: ${e.toString()}');
      print('💬 ChatProvider: Error loading messages: $e');
    }
  }

  // Send a message
  Future<bool> sendMessage(String questionId, String text) async {
    if (text.trim().isEmpty) {
      _setError('Message cannot be empty');
      return false;
    }

    try {
      _isSendingMessage = true;
      _clearError();
      notifyListeners();

      final messageDto = SendMessageDto(
        questionId: questionId,
        text: text.trim(),
      );

      final message = await ApiService().sendMessage(messageDto);

      // Add the new message to the local list
      if (_messagesByQuestion[questionId] != null) {
        _messagesByQuestion[questionId]!.add(message);
      } else {
        _messagesByQuestion[questionId] = [message];
      }

      _isSendingMessage = false;
      _setState(ChatState.success);
      return true;
    } catch (e) {
      _isSendingMessage = false;
      _setError('Failed to send message: ${e.toString()}');
      print('💬 ChatProvider: Error sending message: $e');
      return false;
    }
  }

  // Refresh messages for a question
  Future<void> refreshMessages(String questionId) async {
    await loadMessages(questionId);
  }

  // Clear messages for a question (useful when leaving chat)
  void clearMessagesForQuestion(String questionId) {
    _messagesByQuestion.remove(questionId);
    notifyListeners();
  }

  // Clear all messages
  void clearAllMessages() {
    _messagesByQuestion.clear();
    notifyListeners();
  }

  // Add a message locally (useful for optimistic updates)
  void addMessageLocally(String questionId, Message message) {
    if (_messagesByQuestion[questionId] != null) {
      _messagesByQuestion[questionId]!.add(message);
    } else {
      _messagesByQuestion[questionId] = [message];
    }
    notifyListeners();
  }

  // Get the latest message for a question
  Message? getLatestMessage(String questionId) {
    final messages = _messagesByQuestion[questionId];
    if (messages == null || messages.isEmpty) return null;
    return messages.last;
  }

  // Check if current user sent the message
  bool isMyMessage(Message message, String currentUserId) {
    return message.senderId == currentUserId;
  }

  // Real-time polling methods
  void startPolling(String questionId) {
    _activeQuestionId = questionId;
    _isPollingEnabled = true;

    // Stop any existing timer
    _pollingTimer?.cancel();

    // Start new timer
    _pollingTimer = Timer.periodic(_pollingInterval, (timer) {
      if (_isPollingEnabled && _activeQuestionId == questionId) {
        _pollMessages(questionId);
      }
    });
  }

  void stopPolling() {
    _isPollingEnabled = false;
    _activeQuestionId = null;
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  void pausePolling() {
    _isPollingEnabled = false;
  }

  void resumePolling() {
    if (_activeQuestionId != null) {
      _isPollingEnabled = true;
    }
  }

  Future<void> _pollMessages(String questionId) async {
    try {
      // Don't poll if already loading messages manually
      if (_isLoadingMessages) return;

      print('💬 ChatProvider: Polling messages for question $questionId...');
      final messages = await ApiService().getMessages(questionId);

      // Check if we have new messages
      final currentMessages = _messagesByQuestion[questionId] ?? [];
      if (messages.length > currentMessages.length) {
        print('💬 ChatProvider: Found ${messages.length - currentMessages.length} new messages');
        _messagesByQuestion[questionId] = messages;
        notifyListeners();
      } else if (messages.length != currentMessages.length) {
        // Handle case where message count changed (e.g., message deleted)
        print('💬 ChatProvider: Message count changed, updating list');
        _messagesByQuestion[questionId] = messages;
        notifyListeners();
      }
    } catch (e) {
      print('💬 ChatProvider: Error polling messages: $e');
      // Don't show error for polling failures to avoid spam
    }
  }

  @override
  void dispose() {
    stopPolling();
    _messagesByQuestion.clear();
    super.dispose();
  }
}
