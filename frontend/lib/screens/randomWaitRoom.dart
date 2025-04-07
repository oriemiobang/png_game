import 'package:flutter/material.dart';
import 'package:png_game/classes/data.dart';
import 'package:provider/provider.dart';

class RandomWaitRoom extends StatefulWidget {
  const RandomWaitRoom({super.key});

  @override
  State<RandomWaitRoom> createState() => _RandomWaitRoomState();
}

class _RandomWaitRoomState extends State<RandomWaitRoom> {
  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<Data>(context);
    print('these are the random games: ${Data().randomGames}');

    if (dataProvider.randomRoomGame?['player2'] != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamed(context, '/play_board');
      });
    }
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text('Wait here'),
      ),
    );
  }
}
