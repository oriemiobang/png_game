import 'package:flutter/material.dart';
import 'package:png_game/classes/data.dart';
import 'package:png_game/classes/play_board_classes.dart';
import 'package:png_game/screens/play_solo.dart';
import 'package:png_game/screens/randomWaitRoom.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:png_game/screens/create_room.dart';
import 'package:png_game/screens/home_page.dart';
import 'package:png_game/screens/join_room.dart';
import 'package:png_game/screens/play_board.dart';
import 'package:png_game/screens/scan_qr.dart';
import 'package:png_game/services/playboard_provider.dart';
import 'package:png_game/services/socket_service.dart';
import 'package:png_game/screens/sign_in.dart';
import 'package:png_game/screens/sign_up.dart';

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

// changing route to go_router for easy routing
final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => HomePage(),
    ),
    GoRoute(
      path: '/join_game',
      builder: (context, state) => JoinRoom(),
    ),
    GoRoute(
      path: '/create_game',
      builder: (context, state) => CreateRoom(),
    ),
    GoRoute(
      path: '/play_board',
      builder: (context, state) => PlayBoard(),
    ),
    GoRoute(
      path: '/scan_qr_code',
      builder: (context, state) => ScanQrCode(),
    ),
    GoRoute(
      path: '/random_wait_room',
      builder: (context, state) => RandomWaitRoom(),
    ),
    GoRoute(
      path: '/play_solo',
      builder: (context, state) => PlaySolo(),
    ),
    GoRoute(
      path: '/signin',
      builder: (context, state) => SignIn(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => SignUp(),
    ),
    // GoRoute(
    //   path: '/details/:id',
    //   builder: (context, state) {
    //     final id = state.pathParameters['id'];
    //     return DetailsPage(id: id!);
    //   },
    // ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      // darkTheme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      title: 'PNG Game',
    );
  }
}
