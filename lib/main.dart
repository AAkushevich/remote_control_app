import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:remote_control_app/repositories/api_repository.dart';
import 'package:remote_control_app/services/api_service.dart';
import 'app.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  final dio = Dio();

  runApp(App(apiRepository: ApiRepository(ApiService(dio)))

  );
}
