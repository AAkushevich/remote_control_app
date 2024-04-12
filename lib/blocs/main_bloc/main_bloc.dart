import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remote_control_app/utils/Logger.dart';
import 'package:remote_control_app/blocs/main_bloc/main_event.dart';
import 'package:remote_control_app/blocs/main_bloc/main_state.dart';
import 'package:remote_control_app/repositories/api_repository.dart';
import 'package:remote_control_app/repositories/socket_repository.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';

import 'package:remote_control_app/utils/constant_values.dart';

class MainBloc extends Bloc<MainEvent, MainState> {

  final ApiRepository _apiRepository;
  final SocketRepository _socketRepository;
  late MethodChannel methodChannel = const MethodChannel(ConstantValues.methodChannelName);
  Uint8List? screenshotData = Uint8List(0);

  MainBloc(super.initialState,
      {required ApiRepository apiRepository,
        required SocketRepository socketRepository
      }) : _apiRepository = apiRepository,
        _socketRepository = socketRepository {
    _apiRepository.toString(); // Remove it
    on<InitializeConnection>(_onInitializeConnection);
    on<StartScreenSharing>(_startScreenSharing);
    on<SetScreenshotCallback>(_getScreenshot);

  }

  void _onInitializeConnection(InitializeConnection event, Emitter<MainState> emit) {
    bool isConnected = _socketRepository.initializeConnection();

    emit(state.copyWith(
      connectionStatus: isConnected ? ConnectionStatus.connected : ConnectionStatus.error,
    ));
  }

  void _startScreenSharing(StartScreenSharing event, Emitter<MainState> emit) async {
    try {
      methodChannel.invokeMethod(ConstantValues.nativeStartScreenSharingMethod);
      listenForScreenshots();
    } on PlatformException catch (e) {
      Logger.Red.log("Failed to start screen sharing: '${e.message}'.");
    }
  }

  void _getScreenshot(SetScreenshotCallback event, Emitter<MainState> emit) async {
    _socketRepository.setScreenshotCallback(screenshotCallback);
  }

  void screenshotCallback(Uint8List screenshotData) async {
    emit(state.copyWith(
        screenShareStatus: ScreenShareStatus.displayScreenshot,
        screenshotBytes: screenshotData
    ));
  }

  void listenForScreenshots() {
    methodChannel.setMethodCallHandler((call) async {
      if (call.method == ConstantValues.nativeReceiveScreenshotMethod) {
        final List<int> screenshotData = call.arguments.cast<int>();
        Uint8List screnshot = Uint8List.fromList(screenshotData);
       _socketRepository.sendScreenshot(screnshot);
      }
    });
  }

}
