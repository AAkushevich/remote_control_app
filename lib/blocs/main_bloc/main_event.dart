import 'dart:typed_data';

sealed class MainEvent{
  const MainEvent();
}

final class InitializeConnection extends MainEvent {
  const InitializeConnection();
}

final class SendScreenshot extends MainEvent {
  final Uint8List screenshotBytes;
  const SendScreenshot(this.screenshotBytes);
}

final class SetScreenshotCallback extends MainEvent {
  final Function(Uint8List) callback;

  SetScreenshotCallback(this.callback);
}