import 'dart:io';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
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
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  final TextEditingController textController = TextEditingController();

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

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
            Expanded(flex: 4, child: buildQrView(context)),
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
                          child: FutureBuilder(
                            future: controller?.getFlashStatus(),
                            builder: (context, snapshot) {
                              return IconButton(
                                icon: (snapshot.data ?? false)
                                  ? const Icon(Icons.flashlight_off_outlined)
                                  : const Icon(Icons.flashlight_on_outlined),
                                tooltip: "Toggle flashlight",
                                onPressed: () async {
                                  await controller?.toggleFlash();
                                  setState(() {});
                                },
                              );
                            }
                          )
                        ),
                        Container(
                          margin: const EdgeInsets.all(8),
                          child: IconButton(
                            icon: const Icon(Icons.flip_camera_ios_outlined),
                            tooltip: "Flip camera",
                            onPressed: () async {
                              await controller?.flipCamera();
                              setState(() {});
                            },
                          )
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

  Widget buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: (controller) => onQRViewCreated(controller, context),
      overlay: QrScannerOverlayShape(
        borderColor: Colors.red,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: scanArea),
      onPermissionSet: (ctrl, perms) => onPermissionSet(context, ctrl, perms),
    );
  }

  void onQRViewCreated(QRViewController controller, BuildContext context) {
    setState(() { this.controller = controller; });
    controller.scannedDataStream.listen((scanData) async {
      if (scanData.code != null) {
        setState(() { scanning = false; });
        sendRequest(scanData.code!, context);
      }
    });
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

  void onPermissionSet(BuildContext context, QRViewController ctrl, bool perms) {
    log('${DateTime.now().toIso8601String()}onPermissionSet $perms');
    if (!perms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}