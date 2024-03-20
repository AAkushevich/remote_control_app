sealed class LoginEvent{
  const LoginEvent();
}

final class LoginRequest extends LoginEvent {
  final String email;
  final String password;
  const LoginRequest(this.email, this.password);
}

final class Logined extends LoginEvent {
  const Logined();
}

final class RegistrationRequest extends LoginEvent {
  final String username;
  final String email;
  final String password;
  const RegistrationRequest(this.username, this.email, this.password);

}

final class Registered extends LoginEvent {
  const Registered();
}
