import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:remote_control_app/blocs/main_bloc/main_bloc.dart';
import 'package:remote_control_app/blocs/main_bloc/main_state.dart';
import 'package:remote_control_app/repositories/api_repository.dart';
import 'package:remote_control_app/repositories/socket_repository.dart';
import 'package:remote_control_app/services/api_service.dart';
import 'package:remote_control_app/services/socket_service.dart';
import 'package:remote_control_app/ui/screens/mobile_view/main_veiw.dart';

class App extends StatelessWidget {
  const App({
    Key? key,
    required this.apiRepository,
    required this.socketService
  }) : super(key: key);

  final ApiRepository apiRepository;
  final ISocketService socketService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.blue).copyWith(
              background: const Color.fromRGBO(14, 14, 14, 1),

        ),
      ),
      home: BlocProvider(
        create: (context) => AppBloc(),
        child: AppView(apiRepository: apiRepository, socketService: socketService,),
      ),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({
    Key? key,
    required this.apiRepository,
    required this.socketService
  }) : super(key: key);

  final ApiRepository apiRepository;
  final ISocketService socketService;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: apiRepository,
      child: BlocProvider(
          child: const MainView(),
          create: (_) =>
              MainBloc(
                  MainState(
                    connectionStatus: ConnectionStatus.notConnected,
                    screenshotBytes: Uint8List(0),
                    remoteRenderer: RTCVideoRenderer()
                  ),
                  apiRepository: ApiRepository(ApiService(Dio())),
                  socketRepository: SocketRepository(socketService: socketService)
              )
      ),
    );
  }
}


class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(const InitialAppState());

  Stream<AppState> mapEventToState(AppEvent event) async* {
    // Handle events if needed
  }
}

abstract class AppEvent {}

abstract class AppState {
  const AppState();

  factory AppState.initial() => const InitialAppState();
}

class InitialAppState extends AppState {
  const InitialAppState();
}
