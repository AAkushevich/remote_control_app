import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:remote_control_app/blocs/main_bloc/main_event.dart';
import 'package:remote_control_app/blocs/main_bloc/main_state.dart';
import 'package:remote_control_app/models/Command.dart';
import 'package:remote_control_app/models/DeviceInfo.dart';
import 'package:remote_control_app/models/Message.dart';
import 'package:remote_control_app/services/signaling.dart';
import 'package:remote_control_app/utils/Logger.dart';
import 'package:remote_control_app/utils/constant_values.dart';

class MainBloc extends Bloc<MainEvent, MainState> {

  late MethodChannel methodChannel =
  const MethodChannel(ConstantValues.methodChannelName);
  Uint8List? screenshotData = Uint8List(0);
  late Signaling signaling;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer remoteRenderer = RTCVideoRenderer();
  late Coords startSwipeCoords;
  late Coords updateSwipeCoords;
  late AndroidDeviceInfo androidInfo;
  late DeviceInfo deviceInfo;
  late List<Message> messages = [];
  String? roomId;

  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  MainBloc(super.initialState) {
    if(Platform.isAndroid) {
      getDeviceInfo();
    }
    signaling = Signaling(clientConnectedEvent, messageReceived);

    on<InitializeConnection>(_onInitializeConnection);
    on<StartScreenSharing>(_startScreenSharing);
    on<StopScreenSharing>(_stopScreenSharing);
    on<CreateRoom>(_createRoom);
    on<DisposeEvent>(_dispose);
    on<PerformTouch>(_performTouch);
    on<StartSwipe>(_startSwipe);
    on<UpdateSwipe>(_updateSwipe);
    on<EndSwipe>(_endSwipe);
    on<NextEvent>(_next);
    on<SendMessage>(_sendMessage);
  }

  void clientConnectedEvent() {
    if (WebRTC.platformIsWindows && state.desktopStatus == AppStatus.joinRoom) {
      emit(state.copyWith(
        desktopStatus: AppStatus.room,
      ));
    }
  }

  Future<void> getDeviceInfo() async {
    androidInfo = await deviceInfoPlugin.androidInfo;

    deviceInfo = DeviceInfo(
      androidInfo.device,
      androidInfo.model,
      androidInfo.manufacturer,
      androidInfo.version.release,
      androidInfo.hardware,
      androidInfo.display
    );
  }

  void messageReceived(String message) {
    if (message.startsWith('command:')) {
      String result = message.substring('command:'.length);
      methodChannel.invokeMethod("perform_gesture", result);

    } else if(message.startsWith('info:')) {
      String jsonString = message.substring('info:'.length);
      String validJsonString = convertToJsonString(jsonString);
      Map<String, dynamic> jsonMap = jsonDecode(validJsonString);
      DeviceInfo info = DeviceInfo.fromJson(jsonMap);
      emit(state.copyWith(deviceInfo: info));

    } else if(message.startsWith("message:")) {
      String jsonString = message.substring('message:'.length);
      String validJsonString = convertToJsonString(jsonString);
      Map<String, dynamic> jsonMap = jsonDecode(validJsonString);
      Message msg = Message.fromJson(jsonMap);
      messages.add(msg);
      emit(state.copyWith(messages: messages));

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

    void screenshotCallback(Uint8List screenshotData) async {
      emit(state.copyWith(
          screenShareStatus: ScreenShareStatus.displayScreenshot,
          screenshotBytes: screenshotData
      ));
    }

    void _sendDeviceInfo() {
      signaling.sendDeviceInfo(deviceInfo);
    }

    void _performTouch(PerformTouch event, Emitter<MainState> emit) async {
          signaling.sendRemoteControlCommand(
          Command("touch", event.coords, Coords(0, 0))
      );
    }

    void _startSwipe(StartSwipe event, Emitter<MainState> emit) async {
      startSwipeCoords = event.coords;
    }

    void _updateSwipe(UpdateSwipe event, Emitter<MainState> emit) async {
      updateSwipeCoords = event.coords;
    }

    void _endSwipe(EndSwipe event, Emitter<MainState> emit) async {
      signaling.sendRemoteControlCommand(
          Command("swipe", startSwipeCoords, updateSwipeCoords)
      );
    }

  void _sendMessage(SendMessage event, Emitter<MainState> emit) async {
    signaling.sendMessageToRemoteDevice(event.message);
    messages.add(event.message);
    emit(state.copyWith(messages: messages));
  }

    void _startScreenSharing(StartScreenSharing event,
        Emitter<MainState> emit) async {
      try {
        signaling.openUserMedia(_localRenderer, remoteRenderer);
        await signaling.joinRoom(
          event.roomCode,
          _localRenderer,
        );

        emit(state.copyWith(
          desktopStatus: AppStatus.room,
        ));
        _sendDeviceInfo();
      } on PlatformException catch (e) {
        Logger.Red.log("Failed to start screen sharing: '${e.message}'.");
      }
    }

    void _stopScreenSharing(StopScreenSharing event,
        Emitter<MainState> emit) async {
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

  String convertToJsonString(String input) {
    // Replace single quotes with double quotes
    input = input.replaceAll("'", '"');

    // Add double quotes around keys and string values
    input = input.replaceAllMapped(RegExp(r'(\w+):\s*([^,}]+)'), (match) {
      String key = match.group(1)!;
      String value = match.group(2)!;
      if (!value.startsWith('"') && !value.endsWith('"') && !RegExp(r'^\d+$').hasMatch(value)) {
        value = '"$value"';
      }
      return '"$key": $value';
    });

    return input;
  }
  }

