class LoginState {
  final LoginStatus status;
  final String email;
  final String password;

  const LoginState({
    this.status = LoginStatus.loading,
    required this.email,
    required this.password,
  });

  LoginState copyWith({
    LoginStatus? status,
    String? email,
    String? password,
  }) {
    return LoginState(
        status: status ?? this.status,
        email: email ?? this.email,
        password: password ?? this.password,
    );
  }
}

enum LoginStatus {loading, logined, loginRequest, error}