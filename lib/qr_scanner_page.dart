import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum UserStatus { exists, friends, requested, bad, self }

String toMessage(UserStatus status) {
  switch (status) {
    case UserStatus.exists:
      return "User addded";
    case UserStatus.friends:
      return "User already friends";
    case UserStatus.requested:
      return "User already requested";
    case UserStatus.bad:
      return "User not found";
    case UserStatus.self:
      return "Cannot add yourself";
  }
}

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  QrScannerPageState createState() => QrScannerPageState();
}

class QrScannerPageState extends State<QrScannerPage> {
  bool scanning = false;
  final MobileScannerController controller = MobileScannerController();
  final TextEditingController textController = TextEditingController();
  TorchState _torchState = TorchState.off;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Friends"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(children: <Widget>[
        Container(
          color: Theme.of(context).colorScheme.primary,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              TextButton(
                onPressed: () { setState(() { scanning = false; }); },
                child: Text(
                  "QR Code",
                  style: TextStyle(
                    fontWeight: !scanning ? FontWeight.bold : FontWeight.normal,
                    color: Colors.white
                  ),
                ),
              ),
              TextButton(
                onPressed: () { setState(() { scanning = true; }); },
                child: Text(
                  "QR Scanner",
                  style: TextStyle(
                    fontWeight: scanning ? FontWeight.bold : FontWeight.normal,
                    color: Colors.white
                  ),
                ),
              ),
            ],
          )
        ),
        Expanded(
          child: !scanning ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              QrImageView(
                data: FirebaseAuth.instance.currentUser!.uid,
                version: QrVersions.auto,
                size: 200.0
              ),
              const SizedBox(height: 30),
              const Text(
                "Manually copy user ID:",
                 style: TextStyle(fontWeight: FontWeight.bold)
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(FirebaseAuth.instance.currentUser!.uid),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    tooltip: "Copy to clipboard",
                    onPressed: () async {
                      try {
                        await Clipboard.setData(
                          ClipboardData(text: FirebaseAuth.instance.currentUser!.uid)
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Copied to clipboard")));
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Failed to copy to clipboard")));
                        }
                      }
                    },
                  ),
                ]
              ),
              const Text(
                "Manually add user:",
                 style: TextStyle(fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 250),
                    child: Expanded(
                      child: TextField(
                        controller: textController,
                        decoration: InputDecoration(
                          hintText: "Enter user ID",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0)
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 10
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    tooltip: "Send request",
                    onPressed: () async {
                      sendRequest(textController.text, context);
                      textController.clear();
                    },
                  ),
                ]
              )
            ]
          ) : Column(children: <Widget>[
            Expanded(
              flex: 4,
              // CHANGED: Using the MobileScanner widget.
              child: MobileScanner(
                controller: controller,
                // This is the callback that fires when a QR code is detected.
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty) {
                    final String? uid = barcodes.first.rawValue;
                    if (uid != null && scanning) {
                      // Set scanning to false immediately to prevent multiple scans.
                      setState(() {
                        scanning = false;
                      });
                      sendRequest(uid, context);
                    }
                  }
                },
              ),
            ),
            Expanded(
              flex: 1,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          margin: const EdgeInsets.all(8),
                          child: IconButton(
                            icon: Icon(
                              _torchState == TorchState.off
                                ? Icons.flashlight_off_outlined
                                : Icons.flashlight_on_outlined),
                            tooltip: "Toggle flashlight",
                            onPressed: () async {
                              await controller.toggleTorch();
                              setState(() {
                                _torchState = _torchState == TorchState.on
                                  ? TorchState.off : TorchState.on;
                              });
                            }
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.all(8),
                          child: IconButton(
                            icon: const Icon(
                                Icons.flip_camera_ios_outlined),
                            tooltip: "Flip camera",
                            // CHANGED: Using the new controller's switchCamera method.
                            onPressed: () => controller.switchCamera(),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            )
          ])
        )
      ])
    );
  }

  void sendRequest(String uid, BuildContext context) async {
    UserStatus status;

    if (uid == FirebaseAuth.instance.currentUser!.uid) {
      status = UserStatus.self;
    } else {
      status = await FirebaseFirestore.instance.collection("network")
        .doc(uid).get().then((value) {
          if (!value.exists) {
            return UserStatus.bad;
          } else if (value["friends"].contains(FirebaseAuth.instance.currentUser!.uid)) {
            return UserStatus.friends;
          } else if (value["requests"].contains(FirebaseAuth.instance.currentUser!.uid)) {
            return UserStatus.requested;
          } else {
            return UserStatus.exists;
          }
        });
    }

    if (status == UserStatus.exists) {
      FirebaseFirestore.instance.collection("network").doc(uid).update({
        "requests": FieldValue.arrayUnion([
          FirebaseAuth.instance.currentUser!.uid
        ])
      });
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(toMessage(status)),
        duration: const Duration(seconds: 2),
      ));
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}