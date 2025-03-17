import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:png_game/screens/scan_qr.dart';
import 'package:png_game/services/socket_service.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class JoinRoom extends StatefulWidget {
  const JoinRoom({super.key});

  @override
  State<JoinRoom> createState() => _JoinRoomState();
}

class _JoinRoomState extends State<JoinRoom> {
  SocketService socketService = SocketService();
  String gameCode = '';

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  String qr_data = '';
  final myController = TextEditingController();

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
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Center(
              child: const Text('Challenge your friend',
                  style: TextStyle(fontSize: 18)),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: 40,
                  width: 210,
                  child: TextField(
                    controller: myController,
                    onChanged: (value) {
                      setState(() {
                        gameCode = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter room code',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.camera_alt, size: 45),
                  onPressed: () async {
                    final scannedData = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ScanQrCode()),
                    );

                    if (scannedData != null) {
                      setState(() {
                        qr_data = scannedData;
                        myController.text = scannedData;
                      });
                      print("Scanned QR Code: $scannedData");
                      // Use the scanned data here (e.g., open a URL, store it, etc.)
                    }
                  },
                ),
                Container(
                  height: 35,
                  color: Colors.green,
                  child: TextButton(
                    onPressed: () {
                      final socketService =
                          Provider.of<SocketService>(context, listen: false);
                      socketService.joinGame(gameCode);

                      // Listen for changes in gameJoined
                      socketService.addListener(() {
                        if (socketService.gameJoined) {
                          Navigator.pushReplacementNamed(
                              context, '/play_board');
                        }
                      });
                    },
                    child: const Text(
                      'Join room',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }
}
