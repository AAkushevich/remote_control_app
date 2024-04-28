import 'dart:typed_data';

sealed class MainEvent{
  const MainEvent();
}

final class InitializeConnection extends MainEvent {
  const InitializeConnection();
}

final class SendScreenshot extends MainEvent {
  final Uint8List screenshotChunk;
  const SendScreenshot(this.screenshotChunk);
}


final class ListenForScreenshots extends MainEvent {
  const ListenForScreenshots();
}

final class SetScreenshotCallback extends MainEvent {
  SetScreenshotCallback();
}


final class StartScreenSharing extends MainEvent {
  final String roomCode;
  const StartScreenSharing(this.roomCode);
}

final class StopScreenSharing extends MainEvent {
  const StopScreenSharing();
}

final class CreateRoom extends MainEvent {
  const CreateRoom();
}

final class ScanQrCode extends MainEvent {
  const ScanQrCode();
}