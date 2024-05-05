import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:remote_control_app/blocs/main_bloc/main_bloc.dart';
import 'package:remote_control_app/blocs/main_bloc/main_event.dart';
import 'package:remote_control_app/blocs/main_bloc/main_state.dart';
import 'package:remote_control_app/ui/widgets/wave_button.dart';
import 'package:remote_control_app/utils/Logger.dart';
import 'package:toasty_box/toast_service.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  MainViewState createState() => MainViewState();
}

class MainViewState extends State<MainView> {

  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();

    context.read<MainBloc>().add(const InitializeConnection());

    if (Platform.isWindows) {
      context.read<MainBloc>().add(const ListenForScreenshots());
    }
  }

  @override
  void dispose() {
    context.read<MainBloc>().add(const DisposeEvent());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MainBloc, MainState>(
      listener: (context, state) {},
      builder: (BuildContext context, MainState state) {
        return Scaffold(
          body: Center(
            child: Platform.isWindows
                ? // Windows View
                Center(child: displayDesktopView())
                :  Center(child: displayMobileView()),
          ),
        );
      },
    );
  }

  Widget displayDesktopView() {
    switch (context.read<MainBloc>().state.desktopStatus) {
      case AppStatus.main:
        return WaveButton(
          backgroundColor: Colors.white,
          child: const Text("Создать комнату",
              style: TextStyle(
                fontFamily: 'Montserrat',
              )),
          onPressed: () {
            context.read<MainBloc>().add(const CreateRoom());
          },
        );
      case AppStatus.joinRoom:

        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            color: Color.fromRGBO(14, 14, 14, 1)
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 30.0, left: 50, bottom: 15),
                child: Text(
                  "Есть два способа подключения.",
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 28
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.49,
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text(
                          "Отсканируйте QR-код, через приложение на телефоне.",
                          style: TextStyle(
                              fontFamily: 'Montserrat',
                              color: Colors.white,
                              fontSize: 22
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 48),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.4,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(35))
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: PrettyQrView(
                                qrImage: QrImage(
                                  QrCode(
                                    8,
                                    QrErrorCorrectLevel.H,
                                  )..addData(context.read<MainBloc>().state.roomCode),
                                ),
                                decoration: const PrettyQrDecoration(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    width: 0.5,
                    height: MediaQuery.of(context).size.height * 0.55,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.49,
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Или введите этот код в приложении.",
                          style: TextStyle(
                              fontFamily: 'Montserrat',
                              color: Colors.white,
                              fontSize: 22
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 48),
                          child: Center(
                            child: Text(
                              context.read<MainBloc>().state.roomCode,
                              style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  color: Colors.white,
                                  fontSize: 32),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: WaveButton(
                            child: const Icon(Icons.copy, color: Colors.black,),
                            backgroundColor: Colors.white,
                            onPressed: () {
                              final data = ClipboardData(text: context.read<MainBloc>().state.roomCode);
                              Clipboard.setData(data);
                              ToastService.showToast(
                                context,
                                message: "Скопировано в буфер обмена.",
                                shadowColor: Colors.black
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 36, bottom: 36),
                    child: WaveButton(
                      backgroundColor: Colors.white,
                      child: const Text("Вернуться",
                          style: TextStyle(
                              fontFamily: 'Montserrat',
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold
                          )),
                      onPressed: () {},
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 36, bottom: 36),
                    child: WaveButton(
                      backgroundColor: Colors.white,
                      child: const Text("Next",
                          style: TextStyle(
                              fontFamily: 'Montserrat',
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold
                          )),
                      onPressed: () {
                        context.read<MainBloc>().add(
                            const NextEvent()
                        );
                      },
                    ),
                  )
                ],
              ),
            ],
          ),
        );
      case AppStatus.room:
        return Stack(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              height: MediaQuery.of(context).size.height * 0.9,
              width: MediaQuery.of(context).size.width * 0.23,
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.all(Radius.circular(20))
              ),
              child: GestureDetector(
                child: RTCVideoView(
                    context.read<MainBloc>().remoteRenderer
                ),

                onTapDown: (details) {
                  context.read<MainBloc>().add(RemoteCommand(
                      "GestureDetector details.globalPosition.dx: ${details.globalPosition.dx}, details.globalPosition.dy: ${details.globalPosition.dy}"
                  ));
                  /*Logger.Cyan.log("GestureDetector details.globalPosition.dx: ${details.globalPosition.dx}, details.globalPosition.dy: ${details.globalPosition.dy}");*/
                },
              ),
            )
          ],
            
        );
    }
  }

  Widget displayMobileView() {
    switch (context.read<MainBloc>().state.desktopStatus) {
      case AppStatus.main:
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text("Введите код, чтобы подключиться к компьютеру.", style: TextStyle(color: Colors.white),),
            Padding(
              padding: const EdgeInsets.only(top: 96),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                child: TextField(
                  controller: textController,
                  textAlign: TextAlign.start,
                  textAlignVertical: TextAlignVertical.center,
                  showCursor: true,

                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                      hintText: "Введите код",
                    hintStyle: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  WaveButton(
                    backgroundColor: Colors.white,
                    child: const Text("Присоедениться"),
                    onPressed: () {
                      context.read<MainBloc>().add(
                        StartScreenSharing(textController.text)
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: WaveButton(
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.qr_code_scanner, color: Colors.black,),
                      onPressed: () async {
                        String barcode = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Отмена", false, ScanMode.QR);
                        context.read<MainBloc>().add(
                            StartScreenSharing(barcode)
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      case AppStatus.joinRoom:
        return Container();
      case AppStatus.room:
        return Center(
          child: WaveButton(
            child: const Text("Остановить трансляцию",
                style: TextStyle(
                  color: Colors.white,
                )),
            onPressed: () {
              context.read<MainBloc>().add(
                  const StopScreenSharing()
              );
            },
          )
        );
    }
  }

}
