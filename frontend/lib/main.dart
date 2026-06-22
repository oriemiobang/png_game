import 'package:flutter/material.dart';
import 'package:png_game/classes/data.dart';
import 'package:png_game/classes/play_board_classes.dart';
import 'package:png_game/features/home/home_page.dart';
import 'package:png_game/screens/find_match_screen.dart';
import 'package:png_game/screens/create_game.dart';
import 'package:png_game/screens/loading.dart';
import 'package:png_game/screens/game_result_page.dart';
import 'package:png_game/screens/play_solo.dart';
import 'package:png_game/screens/profile_screen.dart';
import 'package:png_game/screens/leaderboard_screen.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:png_game/screens/chat_room.dart';
import 'package:png_game/screens/create_room.dart';
import 'package:png_game/screens/join_room.dart';
import 'package:png_game/screens/play_board.dart';
import 'package:png_game/screens/scan_qr.dart';
import 'package:png_game/services/playboard_provider.dart';
import 'package:png_game/services/socket_service.dart';
import 'package:png_game/screens/sign_in.dart';
import 'package:png_game/screens/sign_up.dart';
import 'package:png_game/services/auth_api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthApiService _authApiService;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authApiService = AuthApiService();
    _router = GoRouter(
      initialLocation: '/loading',
      refreshListenable: _authApiService,
      redirect: (context, state) {
        final isLoggedIn = _authApiService.user != null;
        final isReady = _authApiService.isReady;
        final location = state.matchedLocation;
        final isAuthRoute = location == '/signin' || location == '/signup';
        final isLoadingRoute = location == '/loading';

        if (!isReady) {
          return isLoadingRoute ? null : '/loading';
        }

        if (!isLoggedIn && !isAuthRoute) {
          return '/signin';
        }

        if (isLoggedIn && (isAuthRoute || isLoadingRoute)) {
          return '/';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/loading',
          builder: (context, state) => const Loading(),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/join_game',
          builder: (context, state) => const JoinRoom(),
        ),
        GoRoute(
          path: '/rooms_page',
          builder: (context, state) => const GameRooms(),
        ),
        GoRoute(
          path: '/create_game',
          builder: (context, state) => const CreateGames(),
        ),
        GoRoute(
          path: '/find_match',
          builder: (context, state) => const FindMatchScreen(),
        ),
        GoRoute(
          path: '/create_room',
          builder: (context, state) {
            final gameId = state.extra as String?;
            return CreateRoom(gameId: gameId ?? '');
          },
        ),
        GoRoute(
          path: '/play_board',
          builder: (context, state) => const PlayBoard(),
        ),
        GoRoute(
          path: '/game_result',
          builder: (context, state) => const GameResultPage(),
        ),
        GoRoute(
          path: '/chat',
          builder: (context, state) => const ChatRoom(),
        ),
        GoRoute(
          path: '/scan_qr_code',
          builder: (context, state) => const ScanQrCode(),
        GoRoute(
          path: '/play_solo',
          builder: (context, state) => const PlaySolo(),
        ),
        GoRoute(
          path: '/signin',
          builder: (context, state) => const SignIn(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignUp(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/leaderboard',
          builder: (context, state) => const LeaderboardScreen(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthApiService>.value(value: _authApiService),
        ChangeNotifierProvider<SocketService>(
          create: (context) => SocketService(),
        ),
        ChangeNotifierProvider<PlayBoardProvider>(
          create: (_) => PlayBoardProvider(),
        ),
        ChangeNotifierProvider<Data>(
          create: (_) => Data(),
        ),
        ChangeNotifierProvider<PlayBoardClasses>(
          create: (_) => PlayBoardClasses(),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
        title: 'PNG Game',
      ),
    );
  }
}