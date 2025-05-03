import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:png_game/classes/data.dart';
// import 'package:png_game/main.dart';
// import 'package:png_game/screens/play_board.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final socketService = Provider.of<SocketService>(context, listen: false);
      final dataProvider = Provider.of<Data>(context, listen: false);

      socketService.addListener(() {
        if (dataProvider.data != null) {
          if (socketService.gameJoined) {
            // Navigator.pushNamed(context, '/play_board');
            context.go('/play_board');
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => PlayBoard()),
            // );
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(forceMaterialTransparency: true,),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
           Text(
            'Challenge your friend',
            style: TextStyle(fontSize: 25, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
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
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15)
              ),
              padding: EdgeInsets.all(15),
              child: QrImageView(
                backgroundColor: Colors.white,
                data: gameId,
                version: QrVersions.auto,
                size: 220.0,
              ),
            ),
          ),

          const SizedBox(
            height: 15,
          ),
          Container(
            height: 40,
            width: 240,
            decoration:  BoxDecoration(color: Colors.green.shade500, 
            borderRadius: BorderRadius.circular(10)
            ),
            child: TextButton.icon(
              icon: Transform.flip(  flipX: true,child: Icon(Icons.reply, size: 30, color: Colors.white,)),
              onPressed: () {
                shareCode();
              },
              label: const Text(
                'Share code',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
            const SizedBox(
                height: 15,
              ),
              IconButton(
                onPressed: () {
                  copyCode();
                },
                icon: const Icon(Icons.copy, size: 40,),
              )
        ]),
      ),
    );
  }
}
