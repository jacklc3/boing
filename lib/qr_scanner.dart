import 'dart:io';
import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  QrScannerPageState createState() => QrScannerPageState();
}

class QrScannerPageState extends State<QrScannerPage> {
  bool scanning = false;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

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
        Expanded(child: !scanning
          ? Center(child: QrImageView(
            data: FirebaseAuth.instance.currentUser?.uid ?? "",
            version: QrVersions.auto,
            size: 200.0))
          : Column(children: <Widget>[
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
      onQRViewCreated: onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.red,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: scanArea),
      onPermissionSet: (ctrl, perms) => onPermissionSet(context, ctrl, perms),
    );
  }

  void onQRViewCreated(QRViewController controller) {
    setState(() { this.controller = controller; });
    controller.scannedDataStream.listen((scanData) async {
      if (scanData.code != null) {
        setState(() { scanning = false; });
        FirebaseFirestore.instance.collection("network")
          .doc(scanData.code!)
          .set({
            "requests": FieldValue.arrayUnion([
              FirebaseAuth.instance.currentUser!.uid
            ])},
            SetOptions(merge: true),
          );
      }
    });
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