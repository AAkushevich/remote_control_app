import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'api_service.g.dart';

abstract class IApiService {
  Future<void> registerUser(Map<String, dynamic> body);
  Future<String> loginUser(Map<String, dynamic> body);
}

@RestApi(baseUrl: "http://192.168.100.2:3000")
abstract class ApiService implements IApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  @POST("/api/user/register")
  @override
  Future<void> registerUser(@Body() Map<String, dynamic> body);

  @POST("/api/user/login")
  @override
  Future<String> loginUser(@Body() Map<String, dynamic> body);
}
