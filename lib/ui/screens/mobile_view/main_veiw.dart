import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remote_control_app/blocs/main_bloc/main_bloc.dart';
import 'package:remote_control_app/blocs/main_bloc/main_event.dart';
import 'package:remote_control_app/blocs/main_bloc/main_state.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  MainViewState createState() => MainViewState();
}

class MainViewState extends State<MainView> {

  late final GlobalKey _boundaryKey;

  @override
  void initState() {
    super.initState();
    _boundaryKey = GlobalKey();
    if(Platform.isWindows)
      context.read<MainBloc>().add(SetScreenshotCallback());
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
            body:
            Center(
              child: Platform.isAndroid ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      context.read<MainBloc>().add(const StartScreenSharing());
                    },
                    child: const Text('Start Screen Sharing'),
                  ),
                ],
              ) : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  context.read<MainBloc>().state.screenshotBytes.isNotEmpty
                    ? Image.memory(
                      context.read<MainBloc>().state.screenshotBytes,
                      height: MediaQuery.of(context).size.height * 0.8,
                      width: MediaQuery.of(context).size.width * 0.4,
                  )
                    : const Text('No screenshot available'),
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

}
