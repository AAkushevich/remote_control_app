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
        status: isConnected ? ConnectionStatus.connected : ConnectionStatus.error,
    ));

  }

  void _onScreenshotTransfer(SendScreenshot event, Emitter<MainState> emit) async {

    _socketRepository.sendScreenshot(event.screenshotBytes);
    // emit(state.copyWith(
    //   status: isConnected ? ConnectionStatus.connected : ConnectionStatus.error,
    // ));

  }

  void _getScreenshot(SetScreenshotCallback event, Emitter<MainState> emit) async {




    _socketRepository.setScreenshotCallback(event.callback);
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

}