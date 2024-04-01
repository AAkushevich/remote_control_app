import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:remote_control_app/ui/screens/mobile_view/main_veiw.dart';

class MobileView extends StatefulWidget {
  const MobileView({Key? key}) : super(key: key);

  @override
  _MobileViewState createState() => _MobileViewState();
}

class _MobileViewState extends State<MobileView> {

  late IO.Socket socket;
  final GlobalKey _boundaryKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    connectToSocket();
    startScreenSharing();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MainView()
      // Center(
      //   child: RepaintBoundary(
      //     key: _boundaryKey,
      //     child: Text('Mobile App'),
      //   ),
      // ),
    );
  }
  //'http://192.168.100.2:3000'
  void connectToSocket() {
    socket = IO.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.onConnect((_) {
      print('Connected to socket server');
    });

    socket.on('disconnect', (_) {
      print('Disconnected from socket server');
    });

    socket.connect();
  }

  void startScreenSharing() async {
    while (true) {
      // Delay before capturing the next screenshot
      await Future.delayed(const Duration(seconds: 1));

      // Trigger a repaint by updating the state
      setState(() {});

      // Capture the current screen as an Image
      ui.Image? image = await screenshot();

      // Convert the Image to a ByteData
      ByteData? byteData = await image?.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        Uint8List byteList = byteData.buffer.asUint8List();

        // Send the screenshot to the server
        socket.emit('screenshot', byteList);
      }
    }
  }
  Future<ui.Image?> screenshot() async {
    try {
      RenderRepaintBoundary? boundary = _boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        print('Boundary is null');
        return null;
      }
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      return image;
    } catch (e) {
      print('Error capturing screenshot: $e');
      return null;
    }
  }



  @override
  void dispose() {
    socket.dispose();
    super.dispose();
  }
}
