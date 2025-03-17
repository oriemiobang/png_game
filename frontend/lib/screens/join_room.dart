import 'package:flutter/material.dart';
import 'package:png_game/services/socket_service.dart';

class JoinRoom extends StatefulWidget {
  const JoinRoom({super.key});

  @override
  State<JoinRoom> createState() => _JoinRoomState();
}

class _JoinRoomState extends State<JoinRoom> {
  SocketService socketService = SocketService();
  String gameCode = '';
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
                  width: 270,
                  child: TextField(
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
                Container(
                    height: 35,
                    color: Colors.green,
                    child: TextButton(
                        onPressed: () {
                          socketService.joinGame(gameCode);
                          Navigator.pushNamed(context, 'play_board');
                        },
                        child: const Text(
                          'Join room',
                          style: TextStyle(color: Colors.black),
                        )))
              ],
            )
          ],
        ),
      ),
    );
  }
}
