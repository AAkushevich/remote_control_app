import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  final TextEditingController codeKeyController = TextEditingController();
  bool isButtonEnabled = false;
  bool isPermissionCalled = false;


  @override
  void initState() {
    super.initState();

    context.read<MainBloc>().add(const InitializeConnection());
    codeKeyController.addListener(_validateInput);
  }

  @override
  void dispose() {
    codeKeyController.removeListener(_validateInput);
    codeKeyController.dispose();
    context.read<MainBloc>().add(const DisposeEvent());
    super.dispose();
  }

  void _validateInput() {
    final text = codeKeyController.text;
    final isValid = RegExp(r'^[a-zA-Z0-9]{20}$').hasMatch(text);
    if(!isValid) {
      _showToast("Invalid input");
    }
    setState(() {
      isButtonEnabled = isValid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MainBloc, MainState>(
      listener: (context, state) {
        if(!isPermissionCalled && context.read<MainBloc>().state.desktopStatus == AppStatus.room) {
          isPermissionCalled = true;
          showAccessibilityDialog(context);
        }
      },
      builder: (BuildContext context, MainState state) {
        return Scaffold(
          body: Center(
            child: displayMobileView(),
          ),
        );
      },
    );
  }

  Widget displayMobileView() {
    switch (context.read<MainBloc>().state.desktopStatus) {
      case AppStatus.main:
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Enter the code to connect to your computer.",
              style: TextStyle(color: Colors.white),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 96),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                child: TextFormField(
                  controller: codeKeyController,
                  textAlign: TextAlign.start,
                  textAlignVertical: TextAlignVertical.center,
                  showCursor: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "Enter a code",
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
                    child: const Text("Connect"),
                    onPressed: () {
                      if (isButtonEnabled) {
                        //_showAccessibilityDialog(context);
                        context
                            .read<MainBloc>()
                            .add(StartScreenSharing(codeKeyController.text));
                      } else {
                        _showToast("Invalid input");
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: WaveButton(
                      backgroundColor: Colors.white,
                      child: const Icon(
                        Icons.qr_code_scanner,
                        color: Colors.black,
                      ),
                      onPressed: () async {
                        //_showAccessibilityDialog(context);
                        String barcode =
                            await FlutterBarcodeScanner.scanBarcode(
                                "#ff6666", "Cancel", false, ScanMode.QR);
                        if(barcode != "-1") {
                          context
                              .read<MainBloc>()
                              .add(StartScreenSharing(barcode));
                        }
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
                        type: context
                                    .read<MainBloc>()
                                    .state
                                    .messages[counter]
                                    .sender ==
                                'pc'
                            ? BubbleType.sendBubble
                            : BubbleType.receiverBubble),
                    alignment: context
                                .read<MainBloc>()
                                .state
                                .messages[counter]
                                .sender ==
                            'pc'
                        ? Alignment.topLeft
                        : Alignment.topRight,
                    margin: const EdgeInsets.only(top: 20),
                    backGroundColor: context
                                .read<MainBloc>()
                                .state
                                .messages[counter]
                                .sender ==
                            'pc'
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
                }),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 18.0),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.95,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0)),
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
                          icon: const Icon(
                            Icons.send,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            context.read<MainBloc>().add(SendMessage(
                                Message(chatTextController.text, "mobile")));
                            chatTextController.text = "";
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Align(
                alignment: Alignment.topLeft,
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0, right: 16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          context
                              .read<MainBloc>()
                              .add(const StopScreenSharing());
                        },
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all(const CircleBorder()),
                          padding: MaterialStateProperty.all(
                              const EdgeInsets.all(20)),
                          backgroundColor: MaterialStateProperty.all(
                              Colors.white), // <-- Button color
                        ),
                        child:
                            const Icon(Icons.stop_rounded, color: Colors.red),
                      ),
                    ),
                  ],
                )),
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
              style: TextStyle(fontFamily: 'Montserrat', color: Colors.white)),
          content: const Text(
              'For the application to work correctly, you must provide the following permission. Settings > Accessibility > remote_control_app.',
              style: TextStyle(fontFamily: 'Montserrat', color: Colors.white)),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok',
                  style:
                      TextStyle(fontFamily: 'Montserrat', color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void openAccessibilitySettings() {
    final AndroidIntent intent = const AndroidIntent(
      action: 'android.settings.ACCESSIBILITY_SETTINGS',
    );
    intent.launch();
  }
  void showAccessibilityDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Enable Accessibility Service',
            style: TextStyle(color: Colors.black),
          ),
          content: const Text(
            'To use this app, you need to enable the accessibility service. '
                'The device you are connected to will be able to control your mobile phone.',
            style: TextStyle(color: Colors.black),
          ),
          actions: <Widget>[
              TextButton(
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Montserrat',
                  ),
                ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
              ),
              TextButton(
                child: const Text(
                  'Open Settings',
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Montserrat',
                  ),
                ),
                onPressed: () {
                  openAccessibilitySettings();
                  Navigator.of(context).pop();
                },

              ),
          ]);
        },
    );
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
