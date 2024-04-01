import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remote_control_app/blocs/main_bloc/main_event.dart';
import 'package:remote_control_app/blocs/main_bloc/main_state.dart';
import 'package:remote_control_app/repositories/api_repository.dart';
import 'package:remote_control_app/repositories/socket_repository.dart';
import 'package:flutter/services.dart';

class MainBloc extends Bloc<MainEvent, MainState> {

  final ApiRepository _apiRepository;
  final SocketRepository _socketRepository;
  final MethodChannel _channel = const MethodChannel('capture_screenshot_channel');
  Uint8List? screenshotData = Uint8List(0);

  MainBloc(super.initialState,
      {required ApiRepository apiRepository,
        required SocketRepository socketRepository
      }) : _apiRepository = apiRepository,
        _socketRepository = socketRepository {
    on<InitializeConnection>(_onInitializeConnection);
    on<SendScreenshot>(_onScreenshotTransfer);
    on<SetScreenshotCallback>(_getScreenshot);
  }

  void _onInitializeConnection(InitializeConnection event, Emitter<MainState> emit) async {

    bool isConnected = _socketRepository.initializeConnection();

    emit(state.copyWith(
        connectionStatus: isConnected ? ConnectionStatus.connected : ConnectionStatus.error,
    ));

  }

  void _onScreenshotTransfer(SendScreenshot event, Emitter<MainState> emit) async {

    _socketRepository.sendScreenshot(event.screenshotChunk);
    // emit(state.copyWith(
    //   status: isConnected ? ConnectionStatus.connected : ConnectionStatus.error,
    // ));

  }

  void _getScreenshot(SetScreenshotCallback event, Emitter<MainState> emit) async {

    _socketRepository.setScreenshotCallback(screenshotCallback);
    // emit(state.copyWith(
    //   status: isConnected ? ConnectionStatus.connected : ConnectionStatus.error,
    // ));

  }

  void startScreenSharing() async {
    try {
      await _channel.invokeMethod('startScreenSharing');
    } on PlatformException catch (e) {
      print("Failed to start screen sharing: '${e.message}'.");
    }
  }

  void screenshotCallback(String chunk) {
    assembleScreenshot(chunk);
  }

  void assembleScreenshot(String chunk) {
    if (chunk.contains("<start>")) {
      chunk = chunk.replaceAll("<start>", "");
      screenshotData = Uint8List.fromList([]);
      screenshotData = chunkToBytes(chunk);
    } else if (chunk.contains("<end>")) {
      chunk = chunk.replaceAll("<end>", "");
      screenshotData = chunkToBytes(chunk);
      emit(state.copyWith(
        screenShareStatus: ScreenShareStatus.displayScreenshot,
        screenshotBytes: screenshotData
      ));
    } else{
      screenshotData = chunkToBytes(chunk);
    }
  }

  Uint8List chunkToBytes(String chunk) {
    return Uint8List.fromList([...screenshotData!, ...utf8.encode(chunk)]);
  }

}
