import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
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
import 'package:toasty_box/toast_service.dart';

class DesktopView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DesktopViewState();
  }

}
class DesktopViewState extends State<DesktopView> {
  TextEditingController chatTextController = TextEditingController();
  late double emulatedScreenHeight;
  late double emulatedScreenWidth;
  late double convertRatio;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MainBloc, MainState>(
      listener: (context, state) {},
      builder: (BuildContext context, MainState state) {
        return Scaffold(
          body: Center(
            child: displayDesktopView(),
          ),

        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<MainBloc>().add(const InitializeConnection());
  }

  @override
  void dispose() {
    context.read<MainBloc>().add(const DisposeEvent());
    super.dispose();
  }

  void calculateScreenRatio() {
    emulatedScreenHeight = MediaQuery.of(context).size.height * 0.9;
    double renderScreenRatio = context.read<MainBloc>().renderScreenHeight / context.read<MainBloc>().renderScreenWidth;
    emulatedScreenWidth = emulatedScreenHeight / renderScreenRatio;
    convertRatio = context.read<MainBloc>().renderScreenHeight / emulatedScreenHeight;
  }

  Widget displayDesktopView() {
    switch (context.read<MainBloc>().state.desktopStatus) {
      case AppStatus.main:
        return WaveButton(
        backgroundColor: Colors.white,
          child: const Text("Create room",
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
                  "There are two connection methods.",
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
                          "Scan the QR code using the app on your phone.",
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
                          "Or enter this code in the application.",
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
                                  message: "Copied to clipboard.",
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
                      child: const Text("Close connection",
                          style: TextStyle(
                              fontFamily: 'Montserrat',
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold
                          )),
                      onPressed: () {
                        context.read<MainBloc>().add(const CancelConnection());
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      case AppStatus.room:
        calculateScreenRatio();
        return Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: emulatedScreenHeight,
                  width: MediaQuery.of(context).size.width * 0.25,
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
                                  chatTextController.text = "";
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
                  height: MediaQuery.of(context).size.height * 0.55,
                  width: MediaQuery.of(context).size.width * 0.3,
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
                        child: Text("Total memory: ${context.read<MainBloc>().state.deviceInfo.totalMemory} Gb",
                            style: const TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'Montserrat',)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 14.0, left: 14.0),
                        child: Text("Used memory: ${context.read<MainBloc>().state.deviceInfo.usedMemory} Gb",
                            style: const TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'Montserrat',)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 14.0, left: 14.0),
                        child: Text("Android version: ${context.read<MainBloc>().state.deviceInfo.androidVersion}",
                            style: const TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'Montserrat',)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 14.0, left: 14.0),
                        child: Text("Api Level: ${context.read<MainBloc>().state.deviceInfo.apiLevel}",
                            style: const TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'Montserrat',)),
                      ),
                      /*Padding(
                        padding: const EdgeInsets.only(top: 14.0, left: 14.0),
                        child: Text("Build Number: ${context.read<MainBloc>().state.deviceInfo.buildNumber}",
                            style: const TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'Montserrat',)),
                      ),*/
                      Padding(
                        padding: const EdgeInsets.only(top: 14.0, left: 14.0),
                        child: Text("Processor: ${context.read<MainBloc>().state.deviceInfo.processorManufacturer} ${context.read<MainBloc>().state.deviceInfo.processorName}",
                            style: const TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'Montserrat',)),
                      ),

                    ],
                  ),
                ),

                Container(
                  alignment: Alignment.centerRight,
                  height: emulatedScreenHeight + 15,
                  width: emulatedScreenWidth + 15,
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
                              details.localPosition.dx * convertRatio,
                              details.localPosition.dy * convertRatio,
                          ))
                      );
                    },
                    onPanStart: (details) {

                      context.read<MainBloc>().add(
                          StartSwipe(Coords(
                              details.localPosition.dx * convertRatio,
                              details.localPosition.dy * convertRatio
                          )
                          ));
                    },
                    onPanUpdate: (details) {
                      context.read<MainBloc>().add(
                          UpdateSwipe(Coords(
                              details.localPosition.dx * convertRatio,
                              details.localPosition.dy * convertRatio
                          )
                          ));
                    },
                    onPanEnd: (details) {
                      context.read<MainBloc>().add(const EndSwipe());
                    },
                  ),
                )
              ],

            ),

            Align(
                alignment: Alignment.bottomLeft,
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 4),
                      child: WaveButton(
                        backgroundColor: Colors.white,
                        child: const Text("Close connection",
                            style: TextStyle(
                                fontFamily: 'Montserrat',
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.bold
                            )),
                        onPressed: () {
                          context.read<MainBloc>().add(
                              const StopScreenSharing()
                          );
                        },
                      ),
                    ),
                  ],
                )),
          ],
        );
    }
  }

}