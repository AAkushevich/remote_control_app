import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remote_control_app/blocs/login_bloc/login_bloc.dart';
import 'package:remote_control_app/blocs/login_bloc/login_state.dart';
import 'package:remote_control_app/ui/screens/mobile_view/login_view.dart';
import 'package:remote_control_app/repositories/api_repository.dart';

class App extends StatelessWidget {
  const App({
    Key? key,
    required this.apiRepository,
  }) : super(key: key);

  final ApiRepository apiRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        create: (context) => AppBloc(),
        child: AppView(apiRepository: apiRepository),
      ),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({
    Key? key,
    required this.apiRepository
  }) : super(key: key);

  final ApiRepository apiRepository;
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
