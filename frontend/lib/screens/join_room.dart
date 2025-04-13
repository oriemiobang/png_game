import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:png_game/classes/data.dart';
// import 'package:png_game/main.dart';
// import 'package:png_game/screens/play_board.dart';
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
  void initState() {
    _listenForGameJoin();
    // TODO: implement initState
    super.initState();
  }

  void _listenForGameJoin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final socketService = Provider.of<SocketService>(context, listen: false);
      final dataProvider = Provider.of<Data>(context, listen: false);

      socketService.addListener(() {
        if (dataProvider.data != null) {
          if (socketService.gameJoined) {
            context.go('/play_board');
          }
          // Navigator.pushNamed(context, '/play_board');

          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => PlayBoard()),
          // );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Center(
              child:
                  Text('Challenge your friend', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(
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
                    decoration: const InputDecoration(
                      hintText: 'Enter room code',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt, size: 45),
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
                        gameCode = scannedData;
                        socketService.joinGame(scannedData);
                        Data().updateGameId(scannedData);
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
                      socketService.joinGame(gameCode);
                      Data().updateGameId(gameCode);
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
