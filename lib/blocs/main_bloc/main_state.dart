import 'dart:typed_data';

class MainState {
  final ConnectionStatus connectionStatus;
  final ScreenShareStatus screenShareStatus;
  final Uint8List screenshotBytes;

  const MainState({
    this.connectionStatus = ConnectionStatus.notConnected,
    this.screenShareStatus = ScreenShareStatus.offline,
    required this.screenshotBytes,
  });

  MainState copyWith({
    ConnectionStatus? connectionStatus,
    ScreenShareStatus? screenShareStatus,
    Uint8List? screenshotBytes,
  }) {
    return MainState(
      connectionStatus: connectionStatus ?? this.connectionStatus,
      screenShareStatus: screenShareStatus ?? this.screenShareStatus,
      screenshotBytes: screenshotBytes ?? this.screenshotBytes,
    );
  }
}

enum ConnectionStatus { connected, notConnected, error }
enum ScreenShareStatus { displayScreenshot, startCapturing, stopSharing, offline }
