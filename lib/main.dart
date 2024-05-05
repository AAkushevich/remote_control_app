import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:remote_control_app/firebase_options.dart';
import 'package:remote_control_app/repositories/api_repository.dart';
import 'package:remote_control_app/services/api_service.dart';
import 'package:remote_control_app/services/socket_service.dart';

import 'app.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final dio = Dio();

  runApp(
      App(
        apiRepository: ApiRepository(ApiService(dio)),
        socketService: SocketService()
      )
  );
}
