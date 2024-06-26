/*
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:remote_control_app/models/DeviceInfo.dart';
import 'package:remote_control_app/ui/screens/MobileView.dart';
import 'package:remote_control_app/ui/widgets/wave_button.dart';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:remote_control_app/blocs/main_bloc/main_bloc.dart';
import 'package:remote_control_app/blocs/main_bloc/main_event.dart';
import 'package:remote_control_app/blocs/main_bloc/main_state.dart';

class MockMainBloc extends MockBloc<MainEvent, MainState> implements MainBloc {}

void main() {
  late MockMainBloc mockMainBloc;

  setUp(() {
    mockMainBloc = MockMainBloc();
    when(() => mockMainBloc.state).thenReturn(MainState(
        connectionStatus: ConnectionStatus.notConnected,
        screenshotBytes: Uint8List(0),
        remoteRenderer: RTCVideoRenderer(),
        deviceInfo: DeviceInfo("", "", "", "", "", ""),
        messages: []
    ),);
  });

  testWidgets('MobileView validation test', (WidgetTester tester) async {
    // Оборачиваем виджет MobileView в BlocProvider
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<MainBloc>(
          create: (_) => mockMainBloc,
          child: MobileView(),
        ),
      ),
    );

    // Находим текстовое поле
    final textField = find.byType(TextFormField);

    // Проверяем, что кнопка Connect изначально неактивна
    expect(find.widgetWithText(WaveButton, 'Connect'), findsOneWidget);
    expect(
      tester
          .widget<ElevatedButton>(find.widgetWithText(WaveButton, 'Connect'))
          .onPressed,
      isNull,
    );

    // Вводим некорректный код
    await tester.enterText(textField, 'invalid_code');
    await tester.pump();

    // Проверяем, что кнопка Connect все еще неактивна
    expect(
      tester
          .widget<ElevatedButton>(find.widgetWithText(WaveButton, 'Connect'))
          .onPressed,
      isNull,
    );

    // Вводим корректный код
    await tester.enterText(textField, '12345678901234567890');
    await tester.pump();

    // Проверяем, что кнопка Connect активна
    expect(
      tester
          .widget<ElevatedButton>(find.widgetWithText(WaveButton, 'Connect'))
          .onPressed,
      isNotNull,
    );
  });
}*/
