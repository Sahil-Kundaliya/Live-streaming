import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:live_streaming/constants/app_styles.dart';
import 'package:live_streaming/services/agora_service.dart';

class StreamViewerScreen extends StatefulWidget {
  final String channelName;

  const StreamViewerScreen({
    super.key,
    required this.channelName,
  });

  @override
  State<StreamViewerScreen> createState() => _StreamViewerScreenState();
}

class _StreamViewerScreenState extends State<StreamViewerScreen> {
  final _agoraService = AgoraService();
  bool _isConnected = false;
  int? _remoteUid;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _agoraService.initialize();
    _agoraService.engine?.registerEventHandler(RtcEngineEventHandler(
      onError: (err, msg) {
        _showError('Error: $msg');
      },
      onJoinChannelSuccess: (connection, elapsed) {
        setState(() => _isConnected = true);
      },
      onUserJoined: (connection, uid, elapsed) {
        setState(() => _remoteUid = uid);
      },
      onUserOffline: (connection, uid, reason) {
        setState(() => _remoteUid = null);
      },
    ));

    await _agoraService.joinAsViewer(widget.channelName);
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
        title: Text('Watching Stream', style: AppStyles.headingStyle),
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
                child: _remoteUid != null
                    ? AgoraVideoView(
                        controller: VideoViewController.remote(
                          rtcEngine: _agoraService.engine!,
                          canvas: VideoCanvas(uid: _remoteUid),
                          connection:
                              RtcConnection(channelId: widget.channelName),
                        ),
                      )
                    : const Center(
                        child: Text(
                          'Waiting for broadcaster...',
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
                if (_isConnected)
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.circle, color: Colors.red, size: 12),
                      SizedBox(width: 8),
                      Text(
                        'Live',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}