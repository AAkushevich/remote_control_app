import 'dart:io';
import 'dart:typed_data';
import 'package:socket_io_client/socket_io_client.dart' as IO;

abstract class ISocketService {
  void sendScreenshot(Uint8List byteList);
  bool connectToSocket();
  void dispose();
  void setScreenshotCallback(Function(Uint8List) callback);

}

class SocketService implements ISocketService {
  late final IO.Socket _socket;
  Function(Uint8List) _screenshotCallback = (data) {};

  SocketService() {
    _socket = IO.io('http://192.168.0.103:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false, // Optionally set autoConnect to false
      'connectTimeout': 5000, // Set the connection timeout to 5 seconds (5000 milliseconds)
    });
    connectToSocket();
  }

  @override
  bool connectToSocket() {

    bool isConnected = false;

    _socket.connect();

    _socket.on('connect', (_) { isConnected = true; });

    _socket.onConnectError((data) =>
        print(data.toString())
    );

    if (Platform.isWindows) {
      // Add listener for 'get_screenshot' event only for PC
      _socket.on('get_screenshot', (data) {
        print('Received screenshot data: $data');
        _screenshotCallback!(data);
      });
    }

    return isConnected;
  }

  @override
  void sendScreenshot(Uint8List byteList) {
    _socket.emit('send_screenshot', byteList);
  }

  @override
  void setScreenshotCallback(Function(Uint8List) callback) {
    _screenshotCallback = callback;
  }

  @override
  void dispose() {
    _socket.dispose();
  }
}
