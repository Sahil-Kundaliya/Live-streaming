import 'package:flutter/material.dart';
import 'package:live_streaming/constants/app_styles.dart';
import 'package:live_streaming/features/live_streaming/screens/screen_share_screen.dart';
import 'package:live_streaming/widgets/join_stream_dialog.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../live_streaming/screens/camera_stream_screen.dart';
import '../widgets/stream_option_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _requestCameraPermissions(BuildContext context) async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CameraStreamScreen(),
          ),
        );
      }
    }
  }

  Future<void> _requestScreenSharePermissions(BuildContext context) async {
    // Add screen share permission logic
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ScreenShareScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppStyles.secondaryColor,
        title: const Text('Live Streaming'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const JoinStreamDialog(),
          );
        },
        backgroundColor: AppStyles.primaryColor,
        child: const Icon(Icons.live_tv),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppStyles.backgroundColor,
              AppStyles.backgroundColor.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                Text(
                  'Choose your streaming mode',
                  style: AppStyles.subheadingStyle,
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    children: [
                      StreamOptionCard(
                        icon: Icons.camera_alt,
                        title: 'Camera Stream',
                        description: 'Stream using device camera',
                        onTap: () => _requestCameraPermissions(context),
                      ),
                      StreamOptionCard(
                        icon: Icons.screen_share,
                        title: 'Screen Share',
                        description: 'Share your screen live',
                        onTap: () => _requestScreenSharePermissions(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 