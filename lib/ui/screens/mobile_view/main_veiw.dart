import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remote_control_app/blocs/main_bloc/main_bloc.dart';
import 'package:remote_control_app/blocs/main_bloc/main_event.dart';
import 'package:remote_control_app/blocs/main_bloc/main_state.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {

  late final GlobalKey _boundaryKey;
  final MethodChannel _channel = const MethodChannel('capture_screenshot_channel');

  @override
  void initState() {
    super.initState();

    _boundaryKey = GlobalKey();

    if(Platform.isWindows) {
      context.read<MainBloc>().add(SetScreenshotCallback());
    }

    _channel.setMethodCallHandler((call) async {
      if (call.method == 'receiveScreenshotData') {
        setState(() {
          context.read<MainBloc>().add(SendScreenshot(call.arguments));
        });
      }
    });

  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MainBloc, MainState>(
      listener: (context, state) { },
      builder: (BuildContext context, MainState state) {
        return RepaintBoundary(
          key: _boundaryKey,
          child: Scaffold(
            body: Center(
              child: Platform.isAndroid ? ElevatedButton(
                onPressed: () {
                  startScreenSharing();
                },
                child: const Text('Start Screen Sharing'),
              ) : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (context.read<MainBloc>().state.screenShareStatus == ScreenShareStatus.displayScreenshot)
                    Image.memory(
                      context.read<MainBloc>().state.screenshotBytes,
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
      },
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
