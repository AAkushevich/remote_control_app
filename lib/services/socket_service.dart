import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:remote_control_app/utils/Logger.dart';
import "package:socket_io_client/socket_io_client.dart";

abstract class ISocketService {
  void sendScreenshot(String chunk);
  bool connectToSocket();
  void dispose();
  void setScreenshotCallback(Function(String) callback);

}

class SocketService implements ISocketService {
  late final Socket _socket;
  Function(String) _screenshotCallback = (data) {};
  bool isConnected = false;

  SocketService() {
    _socket = io('http://192.168.100.2:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket.onConnect((data) {
      Logger.Green.log("Connected to socket");
      isConnected = true;
    });

    _socket.on('connect_error', (data) {
      Logger.Red.log("Socket connection error");
      isConnected = false;
    });

    _socket.on('connect_timeout', (data) {
      Logger.Red.log("Socket connection timed out: $data");
      isConnected = false;
    });

    _socket.onConnectError((data) => Logger.Red.log("_socket.onConnectError: " + data.toString()));

    if (Platform.isWindows) {
      _socket.on('get_screenshot', (data) {
        _screenshotCallback!(data);
      });
    }

    // Connect to the socket
    connectToSocket();
  }

  @override
  bool connectToSocket() {
    _socket.connect();
    Logger.Blue.log("isConnected: " + isConnected.toString());
    return isConnected;
  }

  void sendScreenshot(String chunk) {
    _socket.emit("send_screenshot", chunk);
  }

  @override
  void setScreenshotCallback(Function(String) callback) {
    _screenshotCallback = callback;
  }

  @override
  void dispose() {
    _socket.dispose();
  }
}
