import 'package:flutter/material.dart';
import 'package:png_game/screens/create_room.dart';
import 'package:png_game/screens/home_page.dart';
import 'package:png_game/screens/join_room.dart';
import 'package:png_game/screens/play_board.dart';
import 'package:png_game/services/socket_service.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => SocketService()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PNG Game',
      routes: {
        '/': (context) => const HomePage(),
        '/join_game': (context) => const JoinRoom(),
        '/create_game': (context) =>  CreateRoom(),
        '/play_board': (context) => const PlayBoard()
      },
    );
  }
}
