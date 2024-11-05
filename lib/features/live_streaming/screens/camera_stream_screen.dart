import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:live_streaming/constants/app_styles.dart';

import '../../../services/agora_service.dart';

class CameraStreamScreen extends StatefulWidget {
  const CameraStreamScreen({super.key});

  @override
  State<CameraStreamScreen> createState() => _CameraStreamScreenState();
}

class _CameraStreamScreenState extends State<CameraStreamScreen> {
  final _agoraService = AgoraService();
  bool _isStreaming = false;
  String _channelName = '';

  @override
  void initState() {
    super.initState();
    _initialize();
    // Generate a random channel name
    _channelName = 'channel-${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> _initialize() async {
    await _agoraService.initialize();
    _agoraService.engine?.registerEventHandler(RtcEngineEventHandler(
      onError: (err, msg) {
        _showError('Error: $msg');
      },
      onJoinChannelSuccess: (connection, elapsed) {
        setState(() => _isStreaming = true);
      },
      onLeaveChannel: (connection, stats) {
        setState(() => _isStreaming = false);
      },
    ));
  }

  Future<void> _toggleStream() async {
    try {
      if (_isStreaming) {
        await _agoraService.leaveChannel();
      } else {
        await _agoraService.startBroadcast(_channelName);
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _agoraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppStyles.secondaryColor,
        title: Text('Camera Stream', style: AppStyles.headingStyle),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppStyles.primaryColor,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: _isStreaming
                    ? AgoraVideoView(
                        controller: VideoViewController(
                          rtcEngine: _agoraService.engine!,
                          canvas: const VideoCanvas(uid: 0),
                        ),
                      )
                    : const Center(
                        child: Text(
                          'Camera Preview',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            color: AppStyles.secondaryColor,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: _toggleStream,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isStreaming ? Colors.red : AppStyles.primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: Text(_isStreaming ? 'Stop Streaming' : 'Start Streaming'),
                ),
                if (_isStreaming) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Channel ID: $_channelName',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const Text(
                    'Share this ID with viewers',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}