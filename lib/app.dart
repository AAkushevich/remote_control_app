import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remote_control_app/blocs/login_bloc/login_bloc.dart';
import 'package:remote_control_app/blocs/login_bloc/login_state.dart';
import 'package:remote_control_app/blocs/main_bloc/main_state.dart';
import 'package:remote_control_app/repositories/socket_repository.dart';
import 'package:remote_control_app/ui/screens/desktop_view/desktop_view.dart';
import 'package:remote_control_app/ui/screens/mobile_view/login_view.dart';
import 'package:remote_control_app/ui/screens/mobile_view/main_veiw.dart';
import 'package:remote_control_app/ui/screens/mobile_view/mobile_view.dart';
import 'package:remote_control_app/repositories/api_repository.dart';

import 'blocs/main_bloc/main_bloc.dart';
class App extends StatelessWidget {
  const App({
    Key? key,
    required this.apiRepository, required this.socketRepository,
  }) : super(key: key);

  final ApiRepository apiRepository;
  final SocketRepository socketRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        create: (context) => AppBloc(),
        child: AppView(apiRepository: apiRepository, socketRepository: socketRepository),
      ),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({
    Key? key,
    required this.apiRepository, required this.socketRepository,
  }) : super(key: key);

  final ApiRepository apiRepository;
  final SocketRepository socketRepository;
  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: apiRepository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (_) =>
                  LoginBloc(
                      const LoginState(email: "", password: ""),
                      apiRepository: apiRepository
                  )
          ),

        ],
        child: LoginView(),
      ),
    );
  }
}


class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(const InitialAppState());

  @override
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
