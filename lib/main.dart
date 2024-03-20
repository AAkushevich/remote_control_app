import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:remote_control_app/repositories/api_repository.dart';
import 'package:remote_control_app/repositories/socket_repository.dart';
import 'package:remote_control_app/services/api_service.dart';
import 'package:remote_control_app/services/socket_service.dart';

import 'app.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  final dio = Dio();

  //await _requestPermissions();

  runApp(App(
        apiRepository: ApiRepository(ApiService(dio)),
        socketRepository: SocketRepository(socketService: SocketService()))
  );
}

Future<void> _requestPermissions() async {
  // Request permissions using permission_handler
  final permissions = [
    Permission.mediaLibrary,
    Permission.accessMediaLocation,
    Permission.microphone,
    // Add more permissions as needed
  ];

  var status = await permissions.request();

  print(status);
}