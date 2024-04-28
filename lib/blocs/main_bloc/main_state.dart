import 'dart:typed_data';

import 'package:flutter_webrtc/flutter_webrtc.dart';

class MainState {
  final ConnectionStatus connectionStatus;
  final ScreenShareStatus screenShareStatus;
  final AppStatus desktopStatus;
  final Uint8List screenshotBytes;
  final RTCVideoRenderer remoteRenderer;
  final String roomCode;

  const MainState({
    this.connectionStatus = ConnectionStatus.notConnected,
    this.screenShareStatus = ScreenShareStatus.offline,
    this.desktopStatus = AppStatus.main,
    required this.remoteRenderer,
    this.roomCode = "",
    required this.screenshotBytes,
  });

  MainState copyWith({
    ConnectionStatus? connectionStatus,
    ScreenShareStatus? screenShareStatus,
    AppStatus? desktopStatus,
    Uint8List? screenshotBytes,
    RTCVideoRenderer? remoteRenderer,
    String? roomCode
  }) {
    return MainState(
      connectionStatus: connectionStatus ?? this.connectionStatus,
      screenShareStatus: screenShareStatus ?? this.screenShareStatus,
      desktopStatus: desktopStatus ?? this.desktopStatus,
      remoteRenderer: remoteRenderer ?? this.remoteRenderer,
      screenshotBytes: screenshotBytes ?? this.screenshotBytes,
      roomCode: roomCode ?? this.roomCode
    );
  }
}

enum ConnectionStatus { connected, notConnected, error }
enum ScreenShareStatus { displayScreenshot, startCapturing, stopSharing, offline }
enum AppStatus { main, joinRoom, room}
