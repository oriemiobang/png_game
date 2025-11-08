import 'package:flutter/material.dart';

class GameRooms extends StatefulWidget {
  const GameRooms({super.key});

  @override
  State<GameRooms> createState() => _GameRoomsState();
}

class _GameRoomsState extends State<GameRooms> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text('Game Rooms Page'),
      ),
    );
  }
}