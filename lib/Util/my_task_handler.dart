import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class MyTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    print('Foreground service started');
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {
    // This is where you can perform actions periodically
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    print('Foreground service destroyed');
  }

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp('/');
    print('Notification pressed');
  }
}
