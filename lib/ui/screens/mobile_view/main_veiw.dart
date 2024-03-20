import 'dart:typed_data';
import 'dart:io';
import 'dart:async';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  _MainViewState createState() => _MainViewState();
}
class _MainViewState extends State<MainView> {
  late final GlobalKey _boundaryKey;
  late Uint8List screenshot;

  final MethodChannel _channel = MethodChannel('capture_screenshot_channel');
  late StreamSubscription _broadcastStreamSubscription;

  @override
  void initState() {
    super.initState();
    _boundaryKey = GlobalKey();
    screenshot = Uint8List(0);
    _broadcastStreamSubscription = EventChannel('screenshot_event_channel')
        .receiveBroadcastStream()
        .listen((dynamic event) {
      if (event['action'] == 'send_screenshot_event') {
        // Handle screenshot event
        List<int> screenshotData = event['screenshotData'];
        // Process the screenshot data as needed
        // For example, display it in an Image widget
      }
    });
  }

  @override
  void dispose() {
    _broadcastStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _boundaryKey,
      child: Scaffold(
        body: Center(
          child: Platform.isAndroid ? ElevatedButton(
            onPressed: () {
              // Optionally trigger a new screenshot capture when the button is pressed
              startScreenSharing();
            },
            child: const Text('Start Screen Sharing'),
          ) : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (screenshot.isNotEmpty)
                Image.memory(
                  screenshot,
                  width: 350,
                  height: 625,
                )
              else
                Text('No screenshot available'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Connect to Mobile'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Cancel Connection'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void startScreenSharing() async {
    try {
      // Invoke method to start screen sharing in native Android code
      await _channel.invokeMethod('startScreenSharing');
      // Listen for incoming screenshot data from native Android code

    } on PlatformException catch (e) {
      print("Failed to start screen sharing: '${e.message}'.");
    }
  }

  void _receiveScreenshot(List<int> screenshotBytes) {
    // Handle the received screenshot bytes here
  }

}
