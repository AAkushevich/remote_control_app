import 'package:remote_control_app/services/api_service.dart';

class ApiRepository {
  final IApiService apiService;

  ApiRepository(this.apiService);

  Future<void> registerUser(String username, String email, String password) async {
    try {
      await apiService.registerUser({
        'username': username,
        'email': email,
        'password': password,
      });
    } catch (e) {
      throw Exception('Failed to register user: $e');
    }
  }

  Future<String> loginUser(String email, String password) async {
    try {
      final token = await apiService.loginUser({
        'email': email,
        'password': password,
      });
      return token;
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }
}
