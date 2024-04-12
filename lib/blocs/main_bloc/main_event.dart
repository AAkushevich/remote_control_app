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

final class StartScreenSharing extends MainEvent {
  const StartScreenSharing();
}

final class ListenForScreenshots extends MainEvent {
  const ListenForScreenshots();
}

final class SetScreenshotCallback extends MainEvent {
  SetScreenshotCallback();
}