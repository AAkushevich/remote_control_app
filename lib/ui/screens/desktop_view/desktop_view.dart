// import 'package:remote_control_app/ui/screens/mobile_view/login_view.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
//
// class DesktopView extends StatefulWidget {
//   const DesktopView({super.key});
//
//   @override
//   _DesktopViewState createState() => _DesktopViewState();
// }
//
// class _DesktopViewState extends State<DesktopView> {
//   late IO.Socket socket;
//   Uint8List? screenshotData;
//
//   @override
//   void initState() {
//     super.initState();
//     connectToSocket();
//   }
//
//   void connectToSocket() {
//     // Connect to the socket server
//     socket = IO.io('http://localhost:3000', <String, dynamic>{
//       'transports': ['websocket'],
//       'autoConnect': false,
//     });
//
//     socket.onConnect((_) {
//       print('Connected to socket server');
//     });
//
//     socket.on('disconnect', (_) {
//       print('Disconnected from socket server');
//     });
//
//     // Register event listener for 'screenshot' event
//     socket.on('screenshot', (data) {print('!!!!!!!!!!!!!!!!!!!!!!!!!!');
//     // Handle received screenshot data
//     setState(() {
//       screenshotData = Uint8List.fromList(data);
//     });
//     });
//
//     // Connect to the server
//     socket.connect();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//         body: Center(
//           child: LoginView(),
//         )
//       // body: Center(
//       //   child: screenshotData != null
//       //       ? Image.memory(screenshotData!) // Display the received screenshot
//       //       : Text('Waiting for screenshot...'),
//       // ),
//     );
//   }
//
//   @override
//   void dispose() {
//     socket.disconnect();
//     super.dispose();
//   }
// }