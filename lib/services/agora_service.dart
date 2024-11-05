import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../config/agora_config.dart';

class AgoraService {
  static final AgoraService _singleton = AgoraService._internal();
  factory AgoraService() => _singleton;
  AgoraService._internal();

  RtcEngine? engine;
  String? channelId;
  bool isInitialized = false;

  Future<void> initialize() async {
    if (isInitialized) return;

    engine = createAgoraRtcEngine();
    await engine!.initialize(RtcEngineContext(
      appId: AgoraConfig.appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    isInitialized = true;
  }

  Future<void> startBroadcast(String channelName) async {
    if (!isInitialized) await initialize();

    channelId = channelName;

    await engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await engine!.enableVideo();
    await engine!.startPreview();

    await engine!.joinChannel(
      token: AgoraConfig.tempToken?? '',
      channelId: channelName,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  Future<void> joinAsViewer(String channelName) async {
    if (!isInitialized) await initialize();

    channelId = channelName;

    await engine!.setClientRole(role: ClientRoleType.clientRoleAudience);
    await engine!.enableVideo();

    await engine!.joinChannel(
      token: AgoraConfig.tempToken ?? '',
      channelId: channelName,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  Future<void> leaveChannel() async {
    await engine?.leaveChannel();
    await engine?.stopPreview();
  }

  Future<void> dispose() async {
    await leaveChannel();
    await engine?.release();
    isInitialized = false;
  }
}
