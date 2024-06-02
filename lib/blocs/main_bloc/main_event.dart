import 'dart:typed_data';

import 'package:remote_control_app/models/Command.dart';
import 'package:remote_control_app/models/Message.dart';

sealed class MainEvent{
  const MainEvent();
}

final class InitializeConnection extends MainEvent {
  const InitializeConnection();
}

final class DisposeEvent extends MainEvent {
  const DisposeEvent();
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


final class NextEvent extends MainEvent {
  const NextEvent();
}

final class PerformTouch extends MainEvent {
  const PerformTouch(this.coords);
  final Coords coords;
}

final class StartSwipe extends MainEvent {
  const StartSwipe(this.coords);
  final Coords coords;
}

final class UpdateSwipe extends MainEvent {
  const UpdateSwipe(this.coords);
  final Coords coords;
}

final class EndSwipe extends MainEvent {
  const EndSwipe();
}

final class SendMessage extends MainEvent {
  final Message message;
  const SendMessage(this.message);
}
