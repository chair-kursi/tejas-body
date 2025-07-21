import 'package:flutter/material.dart';
import 'global_chat_service.dart';

class AppLifecycleService extends WidgetsBindingObserver {
  static final AppLifecycleService _instance = AppLifecycleService._internal();
  factory AppLifecycleService() => _instance;
  AppLifecycleService._internal();

  bool _isInitialized = false;

  void initialize() {
    if (!_isInitialized) {
      WidgetsBinding.instance.addObserver(this);
      _isInitialized = true;
      print('🔄 AppLifecycleService: Initialized');
    }
  }

  void dispose() {
    if (_isInitialized) {
      WidgetsBinding.instance.removeObserver(this);
      _isInitialized = false;
      print('🔄 AppLifecycleService: Disposed');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    print('🔄 AppLifecycleService: App state changed to $state');
    
    switch (state) {
      case AppLifecycleState.resumed:
        // App came to foreground - resume polling
        GlobalChatService().resumePolling();
        break;
      case AppLifecycleState.paused:
        // App went to background - pause polling to save battery
        GlobalChatService().pausePolling();
        break;
      case AppLifecycleState.detached:
        // App is being terminated
        GlobalChatService().stopGlobalPolling();
        break;
      case AppLifecycleState.inactive:
        // App is inactive (e.g., during a phone call)
        // Keep polling but could reduce frequency if needed
        break;
      case AppLifecycleState.hidden:
        // App is hidden but still running
        break;
    }
  }
}
