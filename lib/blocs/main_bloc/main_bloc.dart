import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:remote_control_app/blocs/main_bloc/main_event.dart';
import 'package:remote_control_app/blocs/main_bloc/main_state.dart';
import 'package:remote_control_app/repositories/api_repository.dart';
import 'package:remote_control_app/repositories/socket_repository.dart';
import 'package:remote_control_app/services/signaling.dart';
import 'package:remote_control_app/utils/Logger.dart';
import 'package:remote_control_app/utils/constant_values.dart';

class MainBloc extends Bloc<MainEvent, MainState> {

  final ApiRepository _apiRepository;
  final SocketRepository _socketRepository;
  late MethodChannel methodChannel = const MethodChannel(ConstantValues.methodChannelName);
  Uint8List? screenshotData = Uint8List(0);
  late Signaling signaling;

  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer remoteRenderer = RTCVideoRenderer();
  String? roomId;

  MainBloc(super.initialState,
      {required ApiRepository apiRepository,
        required SocketRepository socketRepository
      }) : _apiRepository = apiRepository,
        _socketRepository = socketRepository {

    signaling = Signaling(clientConnectedEvent);

    on<InitializeConnection>(_onInitializeConnection);
    on<SetScreenshotCallback>(_getScreenshot);
    on<ListenForScreenshots>(_listenForScreenshots);
    on<StartScreenSharing>(_startScreenSharing);
    on<StopScreenSharing>(_stopScreenSharing);
    on<CreateRoom>(_createRoom);
    on<DisposeEvent>(_dispose);
    on<RemoteCommand>(_sendCommand);
    on<NextEvent>(_next);
  }

  void clientConnectedEvent() {
    if(WebRTC.platformIsWindows && state.desktopStatus == AppStatus.joinRoom) {
      emit(state.copyWith(
        desktopStatus: AppStatus.room,
      ));
    }
  }

  void _onInitializeConnection(InitializeConnection event, Emitter<MainState> emit) {
    _localRenderer.initialize();
    remoteRenderer.initialize();

    signaling.onAddRemoteStream = ((stream) {
      remoteRenderer.srcObject = stream;
    });
  }

  void _dispose(DisposeEvent event, Emitter<MainState> emit) async {
    signaling.hangUp(remoteRenderer);
    _localRenderer.dispose();
    remoteRenderer.dispose();
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

  void _listenForScreenshots(ListenForScreenshots event, Emitter<MainState> emit) async {

  }

  void _sendCommand(RemoteCommand event, Emitter<MainState> emit) async {
    signaling.sendCommand(event.command);
  }

  void _startScreenSharing(StartScreenSharing event, Emitter<MainState> emit) async {
    try {
      signaling.openUserMedia(_localRenderer, remoteRenderer);
      signaling.joinRoom(
        event.roomCode,
        _localRenderer,
      );
      emit(state.copyWith(
          desktopStatus: AppStatus.room,
      ));
    } on PlatformException catch (e) {
      Logger.Red.log("Failed to start screen sharing: '${e.message}'.");
    }
  }

  void _stopScreenSharing(StopScreenSharing event, Emitter<MainState> emit) async {
    try {
      signaling.hangUp(remoteRenderer);
      _localRenderer.dispose();
      remoteRenderer.dispose();
      emit(state.copyWith(
          desktopStatus: AppStatus.main
      ));
    } on PlatformException catch (e) {
      Logger.Red.log("${e.message}.");
    }
  }

  void _createRoom(CreateRoom event, Emitter<MainState> emit) async {
    try {
      roomId = await signaling.createRoom(
          _localRenderer);

      emit(state.copyWith(
          desktopStatus: AppStatus.joinRoom,
          roomCode: roomId
      ));
    } on PlatformException catch (e) {
      Logger.Red.log("${e.message}.");
    }
  }


  void _next(NextEvent event, Emitter<MainState> emit) async {
    emit(state.copyWith(
      desktopStatus: AppStatus.room,
    ));
  }
}