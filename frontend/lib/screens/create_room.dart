import 'package:flutter/material.dart';
import 'package:png_game/classes/data.dart';
import 'package:png_game/services/socket_service.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';

class CreateRoom extends StatefulWidget {
  String? gameId;
  CreateRoom({super.key, this.gameId});

  @override
  State<CreateRoom> createState() => _CreateRoomState();
}

class _CreateRoomState extends State<CreateRoom> {
  String? selectedValue; // Stores the selected item
  List<String> items = ['Option 1', 'Option 2', 'Option 3', 'Option 4'];
  String gameId = '';
  // SocketService socketService = SocketService();

  void shareCode() {
    final gameId = Data().gameId;
    Share.share(gameId!);
  }

  void copyCode() {
    final gameId = Data().gameId;

    Clipboard.setData(ClipboardData(text: gameId!));

    Fluttertoast.showToast(
        msg: "Code copied!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: const Color.fromARGB(255, 0, 4, 17),
        textColor: Colors.white,
        fontSize: 16.0);
  }

  @override
  void initState() {
    gameId = widget.gameId!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenForGameJoin();
    });
    // TODO: implement initState
    super.initState();
  }

  void _listenForGameJoin() {
    final socketService = Provider.of<SocketService>(context, listen: false);

    socketService.addListener(() {
      if (socketService.gameJoined) {
        Navigator.pushReplacementNamed(context, '/play_board');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          const Text(
            'Challenge your friend',
            style: TextStyle(fontSize: 18),
          ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment
          //       .spaceBetween, // Space between children horizontally
          //   crossAxisAlignment:
          //       CrossAxisAlignment.center, // Center children vertically
          //   children: [
          // SizedBox(
          //   height: 100,
          //   width: 150,
          //   child: TextField(
          //     decoration: InputDecoration(hintText: 'Enter 4 digits 0 - 9'),
          //   ),
          // ),
          // SizedBox(
          //   width: 145,
          //   height: 50,
          //   child: DropdownButton<String>(
          //     hint: Text("Max minutes"),
          //     value: selectedValue, // Current selected value
          //     onChanged: (newValue) {
          //       setState(() {
          //         selectedValue = newValue;
          //       });
          //     },
          //     items: items.map((String item) {
          //       return DropdownMenuItem<String>(
          //         value: item,
          //         child: Text(item),
          //       );
          //     }).toList(),
          //   ),
          // ),
          //   ],
          // )
          const SizedBox(
            height: 10,
          ),
          Center(
            child: QrImageView(
              data: gameId,
              version: QrVersions.auto,
              size: 200.0,
            ),
          ),

          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 35,
                decoration: const BoxDecoration(color: Colors.green),
                child: TextButton(
                  onPressed: () {
                    shareCode();
                  },
                  child: const Text(
                    'Share code',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              IconButton(
                onPressed: () {
                  copyCode();
                },
                icon: const Icon(Icons.copy),
              )
            ],
          )
        ]),
      ),
    );
  }
}
