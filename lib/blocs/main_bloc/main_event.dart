import 'dart:typed_data';

sealed class MainEvent{
  const MainEvent();
}

final class InitializeConnection extends MainEvent {
  const InitializeConnection();
}

final class SendScreenshot extends MainEvent {
  final String screenshotChunk;
  const SendScreenshot(this.screenshotChunk);
}

final class SetScreenshotCallback extends MainEvent {
  SetScreenshotCallback();
}