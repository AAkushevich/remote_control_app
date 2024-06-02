import 'dart:typed_data';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:remote_control_app/models/DeviceInfo.dart';
import 'package:remote_control_app/models/Message.dart';

class MainState {
  final ConnectionStatus connectionStatus;
  final ScreenShareStatus screenShareStatus;
  final AppStatus desktopStatus;
  final Uint8List screenshotBytes;
  final RTCVideoRenderer remoteRenderer;
  final String roomCode;
  final DeviceInfo deviceInfo;
  final List<Message> messages;

  const MainState({
    this.connectionStatus = ConnectionStatus.notConnected,
    this.screenShareStatus = ScreenShareStatus.offline,
    this.desktopStatus = AppStatus.main,
    required this.remoteRenderer,
    this.roomCode = "",
    required this.deviceInfo,
    required this.screenshotBytes,
    required this.messages
  });

  MainState copyWith({
    ConnectionStatus? connectionStatus,
    ScreenShareStatus? screenShareStatus,
    AppStatus? desktopStatus,
    Uint8List? screenshotBytes,
    RTCVideoRenderer? remoteRenderer,
    String? roomCode,
    DeviceInfo? deviceInfo,
    List<Message>? messages
  }) {
    return MainState(
      connectionStatus: connectionStatus ?? this.connectionStatus,
      screenShareStatus: screenShareStatus ?? this.screenShareStatus,
      desktopStatus: desktopStatus ?? this.desktopStatus,
      remoteRenderer: remoteRenderer ?? this.remoteRenderer,
      screenshotBytes: screenshotBytes ?? this.screenshotBytes,
      roomCode: roomCode ?? this.roomCode,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      messages: messages ?? this.messages
    );
  }
}

enum ConnectionStatus { connected, notConnected, error }
enum ScreenShareStatus { displayScreenshot, startCapturing, stopSharing, offline }
enum AppStatus { main, joinRoom, room}
