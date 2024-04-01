import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remote_control_app/blocs/login_bloc/login_bloc.dart';
import 'package:remote_control_app/blocs/login_bloc/login_event.dart';
import 'package:remote_control_app/blocs/login_bloc/login_state.dart';
import 'package:remote_control_app/blocs/main_bloc/main_bloc.dart';
import 'package:remote_control_app/blocs/main_bloc/main_state.dart';
import 'package:remote_control_app/repositories/api_repository.dart';
import 'package:remote_control_app/repositories/socket_repository.dart';
import 'package:remote_control_app/services/api_service.dart';
import 'package:remote_control_app/services/socket_service.dart';
import 'package:remote_control_app/ui/screens/mobile_view/main_veiw.dart';
import 'package:remote_control_app/ui/screens/mobile_view/registration_view.dart';

class LoginView extends StatelessWidget {

  late TextEditingController emailController;
  late TextEditingController passwordController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late ISocketService _socketService;
  LoginView({super.key}) {
    emailController = TextEditingController();
    passwordController = TextEditingController();
    _socketService = SocketService();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
          if (state.status == LoginStatus.logined) {
            // Navigate to the next screen when login is successful
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) =>
                BlocProvider(
                  child: const MainView(),
                  create: (_) =>
                      MainBloc(
                          MainState(
                            connectionStatus: ConnectionStatus.notConnected,
                            screenshotBytes: Uint8List(0),
                          ),
                          apiRepository: ApiRepository(ApiService(Dio())),
                          socketRepository: SocketRepository(socketService: _socketService)
                      )
                )));
          }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Login'),
        ),
        body: Center(
          child: SizedBox(
            width: Platform.isWindows ? MediaQuery.of(context).size.width * 0.4 : MediaQuery.of(context).size.width,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      // Email regex pattern for basic email validation
                      final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      // Password regex pattern for basic password validation
                      final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
                      if (!passwordRegex.hasMatch(value)) {
                        return 'Password must be at least 8 characters long and contain at least one letter and one number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      //if (_formKey.currentState!.validate()) {
                        context.read<LoginBloc>().add(const LoginRequest(
                        "email.test@example.com", "qwe456zxc"
                        )

                            // emailController.text,
                            // passwordController.text)
                        );
                      //}
                    },
                    child: const Text('Login'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegistrationView()),
                      );
                    },
                    child: const Text('Don\'t have an account? Register'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}