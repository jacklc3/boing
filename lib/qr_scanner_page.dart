import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

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
        actions: [
          if (!scanning) IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Reset QR code",
            onPressed: () => resetQrId(context)
          ) 
        ]
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
          child: !scanning 
            ? StreamBuilder(
                stream: FirebaseFirestore.instance
                  .collection("data")
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      !snapshot.hasData ||
                      snapshot.data!.data() == null) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  String qrid = snapshot.data!.data()!["qrid"] ?? "error";

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        QrImageView(
                          data: qrid,
                          version: QrVersions.auto,
                          size: 200.0
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Manually copy code:",
                          style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(qrid),
                            IconButton(
                              icon: const Icon(Icons.copy),
                              tooltip: "Copy to clipboard",
                              onPressed: () async {
                                try {
                                  await Clipboard.setData(
                                    ClipboardData(text: qrid)
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
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 250),
                              child: TextField(
                                controller: textController,
                                decoration: InputDecoration(
                                  hintText: "Enter user code",
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
                            IconButton(
                              icon: const Icon(Icons.send),
                              tooltip: "Send request",
                              onPressed: () async {
                                sendRequest(textController.text, context);
                                textController.clear();
                              },
                            ),
                          ]
                        ),
                      ]
                    ),
                  );
                }
              )
            : Column(children: <Widget>[
                Expanded(
                  flex: 4,
                  child: MobileScanner(
                    controller: controller,
                    onDetect: (capture) {
                      final List<Barcode> barcodes = capture.barcodes;
                      if (barcodes.isNotEmpty) {
                        final String? qrid = barcodes.first.rawValue;
                        if (qrid != null && scanning) {
                          setState(() {
                            scanning = false;
                          });
                          sendRequest(qrid, context);
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

  void resetQrId(BuildContext context) {
    var currentUser = FirebaseAuth.instance.currentUser!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset QR Code?'),
        content: const Text('This will invalidate your old QR code. Are you sure?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              String qrid = const Uuid().v4();
              FirebaseFirestore.instance.collection("data")
                .doc(currentUser.uid)
                .update({"qrid": qrid});
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("New QR Code generated"),
              ));
              Navigator.of(context).pop();
            },
            child: const Text('Confirm'),
          ),
        ],
      )
    );
  }

  void sendRequest(String qrid, BuildContext context) async {
    UserStatus status;
    String uid = FirebaseAuth.instance.currentUser!.uid;

    if (qrid.trim().isEmpty) {
      return;
    }

    var querySnapshot = await FirebaseFirestore.instance.collection("data")
      .where("qrid", isEqualTo: qrid.trim())
      .limit(1)
      .get();

    if (querySnapshot.docs.isEmpty) {
      status = UserStatus.bad;
    } else {
      String foundQrid = querySnapshot.docs.first.id;

      DocumentSnapshot networkDoc = await FirebaseFirestore.instance
        .collection("network").doc(foundQrid).get();
      Map<String, dynamic> networkData = networkDoc.data() as Map<String, dynamic>;
      
      if (!networkDoc.exists) { 
        status = UserStatus.bad;
      } else if (networkDoc.id == uid) {
        status = UserStatus.self;
      } else if (networkData.keys.contains("friends")
          && networkData["friends"].contains(uid)) {
        status = UserStatus.friends;
      } else if (networkData.keys.contains("requests")
          && networkData["requests"].contains(uid)) {
        status = UserStatus.requested;
      } else {
        status = UserStatus.exists;
      }

      if (status == UserStatus.exists) {
        FirebaseFirestore.instance.collection("network").doc(networkDoc.id).update({
          "requests": FieldValue.arrayUnion([uid])
        });
      }
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