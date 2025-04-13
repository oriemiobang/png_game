import 'package:flutter/material.dart';
import 'package:png_game/classes/data.dart';
import 'package:png_game/classes/play_board_classes.dart';
import 'package:png_game/screens/play_solo.dart';
import 'package:png_game/screens/randomWaitRoom.dart';
import 'package:provider/provider.dart';

import 'package:png_game/screens/create_room.dart';
import 'package:png_game/screens/home_page.dart';
import 'package:png_game/screens/join_room.dart';
import 'package:png_game/screens/play_board.dart';
import 'package:png_game/screens/scan_qr.dart';
import 'package:png_game/services/playboard_provider.dart';
import 'package:png_game/services/socket_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => SocketService(),
        ),
        ChangeNotifierProvider(
          create: (_) => PlayBoardProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => Data(),
        ),
        ChangeNotifierProvider(
          create: (_) => PlayBoardClasses(),
        )
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // darkTheme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      title: 'PNG Game',
      routes: {
        '/': (context) => const HomePage(),
        '/join_game': (context) => const JoinRoom(),
        '/create_game': (context) => CreateRoom(),
        '/play_board': (context) => const PlayBoard(),
        '/scan_qr_code': (context) => const ScanQrCode(),
        '/random_wait_room': (context) => const RandomWaitRoom(),
        '/play_solo': (context) => const PlaySolo()
      },
    );
  }
}
