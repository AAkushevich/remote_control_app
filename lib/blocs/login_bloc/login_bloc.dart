import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remote_control_app/blocs/login_bloc/login_event.dart';
import 'package:remote_control_app/blocs/login_bloc/login_state.dart';
import 'package:remote_control_app/repositories/api_repository.dart';


class LoginBloc extends Bloc<LoginEvent, LoginState> {

  final ApiRepository _apiRepository;


  LoginBloc(super.initialState, {required ApiRepository apiRepository})
      : _apiRepository = apiRepository {
    on<LoginRequest>(_onLoginRequest);
    on<RegistrationRequest>(_onRegisterRequest);
  }

  void _onLoginRequest(LoginRequest event, Emitter<LoginState> emit) async {
    String token = await _apiRepository.loginUser(event.email, event.password);

    // logic that save token and user data

    emit(state.copyWith(
        status: LoginStatus.logined,

    ));
  }

  void _onRegisterRequest(RegistrationRequest event, Emitter<LoginState> emit) async {
    await _apiRepository.registerUser(
        event.username,
        event.email,
        event.password);
    emit(state.copyWith(
      status: LoginStatus.loginRequest,

    ));
  }
}