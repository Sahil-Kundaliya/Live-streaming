import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:live_streaming/constants/app_styles.dart';

class ScreenShareScreen extends StatefulWidget {
  const ScreenShareScreen({super.key});

  @override
  State<ScreenShareScreen> createState() => _ScreenShareScreenState();
}

class _ScreenShareScreenState extends State<ScreenShareScreen> {
  bool _isStreaming = false;

   _initForegroundTask()  {
     FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'screen_share',
        channelName: 'Screen Share Service',
        channelDescription: 'Screen sharing is active',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
        ),
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 5000,
        isOnceEvent: false,
        autoRunOnBoot: false,
        allowWifiLock: true,
      ),
    );
  }

  Future<void> _toggleStream() async {
    if (_isStreaming) {
      await FlutterForegroundTask.stopService();
      // Add your stream stop logic here
    } else {
      await _initForegroundTask();
      await FlutterForegroundTask.startService(
        notificationTitle: 'Screen Sharing',
        notificationText: 'Your screen is being shared',
      );
      // Add your stream start logic here
    }

    setState(() => _isStreaming = !_isStreaming);
  }

  @override
  void dispose() {
    FlutterForegroundTask.stopService();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppStyles.secondaryColor,
        title: Text('Screen Share', style: AppStyles.headingStyle),
        foregroundColor: AppStyles.primaryColor,
      ),
      body: Container(
        height: MediaQuery.sizeOf(context).height,
        width: MediaQuery.sizeOf(context).width,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: AppStyles.cardColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppStyles.primaryColor.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                _isStreaming ? Icons.screen_share : Icons.stop_screen_share,
                size: 80,
                color: _isStreaming ? AppStyles.primaryColor : Colors.grey,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              _isStreaming ? 'Screen is being shared' : 'Screen share stopped',
              style: AppStyles.subheadingStyle,
            ),
            const SizedBox(height: 60),
            ElevatedButton(
              onPressed: _toggleStream,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isStreaming ? Colors.red : AppStyles.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_isStreaming ? Icons.stop : Icons.play_arrow),
                  const SizedBox(width: 10),
                  Text(
                    _isStreaming ? 'Stop Sharing' : 'Start Sharing',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            if (_isStreaming) ...[
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppStyles.cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.circle,
                      color: Colors.red,
                      size: 12,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Live',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}