import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:remote_control_app/blocs/main_bloc/main_bloc.dart';
import 'package:remote_control_app/blocs/main_bloc/main_event.dart';
import 'package:remote_control_app/blocs/main_bloc/main_state.dart';
import 'package:remote_control_app/models/Message.dart';
import 'package:remote_control_app/ui/widgets/wave_button.dart';

class MobileView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MobileViewState();
  }
}

class MobileViewState extends State<MobileView> {
  TextEditingController textController = TextEditingController();
  TextEditingController chatTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MainBloc, MainState>(
      listener: (context, state) {},
      builder: (BuildContext context, MainState state) {
        return Scaffold(
          body: Center(
            child: displayMobileView(),
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
}