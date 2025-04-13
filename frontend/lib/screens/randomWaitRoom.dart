import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:png_game/classes/data.dart';
import 'package:png_game/main.dart';
import 'package:png_game/screens/play_board.dart';
import 'package:provider/provider.dart';

class RandomWaitRoom extends StatefulWidget {
  const RandomWaitRoom({super.key});

  @override
  State<RandomWaitRoom> createState() => _RandomWaitRoomState();
}

class _RandomWaitRoomState extends State<RandomWaitRoom> {
  @override
  void initState() {
    listener();
    // TODO: implement initState
    super.initState();
  }

  void listener() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dataProvider = Provider.of<Data>(context, listen: false);

      dataProvider.addListener(() {
        if (dataProvider.data?['player2'] != null) {
          // Navigator.pushNamed(context, '/play_board');
          context.go('/play_board');
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => const PlayBoard()),
          // );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // final dataProvider = Provider.of<Data>(context);
    // print('these are the random games: ${Data().randomGames}');

    // if (dataProvider.randomRoomGame?['player2'] != null) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     // Navigator.pushNamed(context, '/play_board');
    //     Navigator.push(
    //       context,
    //       MaterialPageRoute(builder: (context) => const PlayBoard()),
    //     );
    //   });
    // }
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text('Wait here'),
      ),
    );
  }
}
