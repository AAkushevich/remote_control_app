import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:remote_control_app/blocs/main_bloc/main_bloc.dart';
import 'package:remote_control_app/blocs/main_bloc/main_event.dart';
import 'package:remote_control_app/blocs/main_bloc/main_state.dart';
import 'package:remote_control_app/models/Command.dart';
import 'package:remote_control_app/models/Message.dart';
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
  TextEditingController chatTextController = TextEditingController();

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
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

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
    double emulatedScreenHeight = MediaQuery.of(context).size.height * 0.9,
        emulatedScreenWidth = MediaQuery.of(context).size.width * 0.23;
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
                            child: const Icon(Icons.copy, color: Colors.black),
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
                            const NextEvent());
                      },
                    ),
                  )
                ],
              ),
            ],
          ),
        );
      case AppStatus.room:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              height: emulatedScreenHeight,
              width: emulatedScreenWidth,
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.all(Radius.circular(20))
              ),
              child: Stack(
                children: [
                  ListView.builder(
                      itemCount: context.read<MainBloc>().state.messages.length,
                      itemBuilder: (BuildContext buildContext, int counter) {
                        return ChatBubble(
                          clipper: ChatBubbleClipper7(
                              type: context.read<MainBloc>().state.messages[counter].sender == 'pc'
                                  ? BubbleType.sendBubble
                                  : BubbleType.receiverBubble
                          ),
                          alignment: context.read<MainBloc>().state.messages[counter].sender == 'pc'
                            ? Alignment.topRight
                            : Alignment.topLeft,
                          margin: const EdgeInsets.only(top: 20),
                          backGroundColor: context.read<MainBloc>().state.messages[counter].sender == 'pc'
                              ? Colors.indigo
                              : Colors.deepPurple,
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.7,
                            ),
                            child: Text(
                                context.read<MainBloc>().state.messages[counter].text,
                                style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      }
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: emulatedScreenWidth * 0.8,
                          child: TextField(
                            cursorColor: Colors.white,
                            controller: chatTextController,
                            textAlign: TextAlign.start,
                            textAlignVertical: TextAlignVertical.center,
                            showCursor: true,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        SizedBox(
                          width: emulatedScreenWidth * 0.10,
                          child: IconButton(
                            icon: const Icon(Icons.send, color: Colors.white,),
                            onPressed: () {
                              context.read<MainBloc>().add(
                                  SendMessage(
                                      Message(chatTextController.text, "pc")
                                  )
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Container(
              height: emulatedScreenHeight,
              width: emulatedScreenWidth,
              padding: const EdgeInsets.only(top: 40),
              decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.all(Radius.circular(10))
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 14.0),
                    child: Text("${context.read<MainBloc>().state.deviceInfo.manufacturer} ${context.read<MainBloc>().state.deviceInfo.model}",
                      style: const TextStyle(color: Colors.white, fontSize: 25, fontFamily: 'Montserrat')
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 14.0, left: 14.0),
                    child: Text("Device: ${context.read<MainBloc>().state.deviceInfo.device}",
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'Montserrat',)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 14.0, left: 14.0),
                    child: Text("Android version: ${context.read<MainBloc>().state.deviceInfo.androidVersion}",
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'Montserrat',)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 14.0, left: 14.0),
                    child: Text("Hardware: ${context.read<MainBloc>().state.deviceInfo.hardware}",
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'Montserrat',)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 14.0, left: 14.0),
                    child: Text("Display: ${context.read<MainBloc>().state.deviceInfo.display}",
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'Montserrat',)),
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.centerRight,
              height: emulatedScreenHeight,
              width: emulatedScreenWidth,
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
                  context.read<MainBloc>().add(
                      PerformTouch(Coords(
                          details.localPosition.dx / emulatedScreenWidth,
                          details.localPosition.dy / emulatedScreenHeight))
                  );
                },
                onPanStart: (details) {
                  context.read<MainBloc>().add(
                      StartSwipe(Coords(
                          details.localPosition.dx / emulatedScreenWidth,
                          details.localPosition.dy / emulatedScreenHeight)
                      ));
                },
                onPanUpdate: (details) {
                  context.read<MainBloc>().add(
                      UpdateSwipe(Coords(
                          details.localPosition.dx / emulatedScreenWidth,
                          details.localPosition.dy / emulatedScreenHeight)
                      ));
                },
                onPanEnd: (details) {
                  context.read<MainBloc>().add(const EndSwipe());
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
                      _showAccessibilityDialog(context);
                      if(textController.text.isNotEmpty) {
                        context.read<MainBloc>().add(
                          StartScreenSharing(textController.text)
                        );
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: WaveButton(
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.qr_code_scanner, color: Colors.black,),
                      onPressed: () async {
                        _showAccessibilityDialog(context);
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
        return Stack(
          children: [
            ListView.builder(
                itemCount: context.read<MainBloc>().state.messages.length,
                itemBuilder: (BuildContext buildContext, int counter) {
                  return ChatBubble(
                    clipper: ChatBubbleClipper7(
                        type: context.read<MainBloc>().state.messages[counter].sender == 'pc'
                            ? BubbleType.sendBubble
                            : BubbleType.receiverBubble
                    ),
                    alignment: context.read<MainBloc>().state.messages[counter].sender == 'pc'
                        ? Alignment.topLeft
                        : Alignment.topRight,
                    margin: const EdgeInsets.only(top: 20),
                    backGroundColor: context.read<MainBloc>().state.messages[counter].sender == 'pc'
                        ? Colors.indigo
                        : Colors.deepPurple,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                      ),
                      child: Text(
                        context.read<MainBloc>().state.messages[counter].text,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 18.0),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.95,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0)
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: TextField(
                          cursorColor: Colors.black,
                          controller: chatTextController,
                          textAlign: TextAlign.start,
                          textAlignVertical: TextAlignVertical.center,
                          showCursor: true,
                          style: const TextStyle(color: Colors.black),
                          decoration: const InputDecoration(
                            hintText: 'Enter your message',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.1,
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.black,),
                          onPressed: () {
                            context.read<MainBloc>().add(
                                SendMessage(
                                    Message(chatTextController.text, "mobile")
                                )
                            );
                          },

                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Align(
                alignment: Alignment.topRight,
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0, right: 16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<MainBloc>().add(
                              const StopScreenSharing()
                          );
                        },
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(const CircleBorder()),
                          padding: MaterialStateProperty.all(const EdgeInsets.all(20)),
                          backgroundColor: MaterialStateProperty.all(Colors.white), // <-- Button color
                        ),
                        child: const Icon(Icons.stop_rounded, color: Colors.red),
                      ),
                    ),
                  ],
                )
            ),
          ],
        );
    }
  }

  Future<void> _showAccessibilityDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Accessibility Permission Required',
              style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.white
              )),
          content: const Text(
              'For the application to work correctly, you must provide the following permission. Settings > Accessibility > remote_control_app.',
              style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.white
              )),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok', style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.white
              )),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),

          ],
        );
      },
    );
  }

  void showChatDialog(BuildContext mContext) {   /// Контекстов дохуя - толку нихуя
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Stack(
            children: [
              SizedBox(
                width: 150,
                child: ListView.builder(
                    itemCount: mContext.read<MainBloc>().state.messages.length,
                    itemBuilder: (BuildContext buildContext, int counter) {
                      return ChatBubble(
                        clipper: ChatBubbleClipper7(
                            type: mContext.read<MainBloc>().state.messages[counter].sender == 'pc'
                                ? BubbleType.sendBubble
                                : BubbleType.receiverBubble
                        ),
                        alignment: Alignment.topRight,
                        margin: const EdgeInsets.only(top: 20),
                        backGroundColor: mContext.read<MainBloc>().state.messages[counter].sender == 'pc'
                            ? Colors.indigo
                            : Colors.purple,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(mContext).size.width * 0.7,
                          ),
                          child: Text(
                            mContext.read<MainBloc>().state.messages[counter].text,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: 150,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextField(
                        cursorColor: Colors.white,
                        controller: chatTextController,
                        textAlign: TextAlign.start,
                        textAlignVertical: TextAlignVertical.center,
                        showCursor: true,
                        style: const TextStyle(color: Colors.white),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.white,),
                        onPressed: () {
                          mContext.read<MainBloc>().add(
                              SendMessage(
                                  Message(chatTextController.text, "pc")
                              )
                          );
                        },

                      )
                    ],
                  ),
                ),
              ),
            ],
          );
        }
    );
  }



}
