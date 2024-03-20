import 'dart:typed_data';

class MainState {
  final ConnectionStatus status;
  final Uint8List screenshotBytes;

  const MainState({
    this.status = ConnectionStatus.notConnected,
    required this.screenshotBytes,
  });

  MainState copyWith({
    ConnectionStatus? status,
    Uint8List? screenshotBytes,
  }) {
    return MainState(
      status: status ?? this.status,
      screenshotBytes: screenshotBytes ?? this.screenshotBytes,
    );
  }
}

enum ConnectionStatus { connected, notConnected, error }
