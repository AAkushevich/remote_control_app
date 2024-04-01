import 'dart:typed_data';
import 'package:remote_control_app/services/socket_service.dart';

class SocketRepository {

  final ISocketService _socketService;

  SocketRepository({required ISocketService socketService})
      : _socketService = socketService;

  bool initializeConnection() {
    return _socketService.connectToSocket();
  }

  void sendScreenshot(String byteList) {
    _socketService.sendScreenshot(byteList);
  }

  void setScreenshotCallback(Function(String) callback) {
    _socketService.setScreenshotCallback(callback);
  }
}