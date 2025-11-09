// services/app_lifecycle_service.dart
import 'package:flutter/widgets.dart';

class AppLifecycleService with WidgetsBindingObserver {
  final VoidCallback onResume;
  final VoidCallback onPause;

  AppLifecycleService({required this.onResume, required this.onPause});

  void initialize() {
    WidgetsBinding.instance.addObserver(this);
    print('AppLifecycleService initialized');
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    print('AppLifecycleService disposed');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('App lifecycle state changed: $state');
    
    switch (state) {
      case AppLifecycleState.resumed:
        print('App resumed - triggering reconnect');
        onResume();
        break;
      case AppLifecycleState.paused:
        print('App paused - triggering disconnect');
        onPause();
        break;
      case AppLifecycleState.inactive:
        print('App inactive - may trigger disconnect soon');
        break;
      case AppLifecycleState.detached:
        print('App detached - triggering disconnect');
        onPause();
        break;
      case AppLifecycleState.hidden:
        print('App hidden - triggering disconnect');
        onPause();
        break;
    }
  }
}