import 'package:flutter/material.dart';
import 'package:png_game/services/socket_service.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
    final socketService = Provider.of<SocketService>(context);
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          Text(
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

          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 35,
                decoration: BoxDecoration(color: Colors.green),
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/play_board');
                  },
                  child: Text(
                    'Share code',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              SizedBox(
                width: 20,
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.copy),
              )
            ],
          )
        ]),
      ),
    );
  }
}
