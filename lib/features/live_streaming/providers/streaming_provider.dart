import 'package:flutter/material.dart';
import 'package:live_streaming/services/agora_service.dart';

class StreamingProvider extends ChangeNotifier {
  final _agoraService = AgoraService();
  bool _isStreaming = false;
  String _channelName = '';
  int? _remoteUid;

  bool get isStreaming => _isStreaming;
  String get channelName => _channelName;
  int? get remoteUid => _remoteUid;

  Future<void> initializeStream() async {
    _channelName = 'channel-${DateTime.now().millisecondsSinceEpoch}';
    await _agoraService.initialize();
  }

  Future<void> toggleStream() async {
    try {
      if (_isStreaming) {
        await _agoraService.leaveChannel();
      } else {
        await _agoraService.startBroadcast(_channelName);
      }
      _isStreaming = !_isStreaming;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> joinStream(String channelName) async {
    try {
      await _agoraService.joinAsViewer(channelName);
      _channelName = channelName;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  void setRemoteUid(int? uid) {
    _remoteUid = uid;
    notifyListeners();
  }

  void dispose() {
    _agoraService.dispose();
    super.dispose();
  }
} 