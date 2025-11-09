import 'package:flutter/material.dart';
import 'package:png_game/classes/data.dart';
import 'package:png_game/classes/play_board_classes.dart';
import 'package:png_game/features/home/home_page.dart';
import 'package:png_game/firebase_options.dart';
import 'package:png_game/firebase_service/auth.dart';
import 'package:png_game/models/my_user.dart';
import 'package:png_game/screens/create_game.dart';
import 'package:png_game/screens/play_solo.dart';
import 'package:png_game/screens/randomWaitRoom.dart';
import 'package:png_game/screens/rooms_page.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:png_game/screens/create_room.dart';
import 'package:png_game/screens/join_room.dart';
import 'package:png_game/screens/play_board.dart';
import 'package:png_game/screens/scan_qr.dart';
import 'package:png_game/services/playboard_provider.dart';
import 'package:png_game/services/socket_service.dart';
import 'package:png_game/screens/sign_in.dart';
import 'package:png_game/screens/sign_up.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:png_game/services/app_lifecycle_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on Exception catch (e) {
    print('Firebase initialization error: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppLifecycleService _lifecycleService;

  @override
  void initState() {
    super.initState();
    _initializeLifecycleService();
  }

  void _initializeLifecycleService() {
    // This will be properly initialized in the build method where we have access to context
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Add AuthService provider
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
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
        // StreamProvider for user authentication state
        StreamProvider<MyUser?>(
          create: (context) => context.read<AuthService>().user,
          initialData: null,
        ),
        // Provider for AppLifecycleService
        Provider<AppLifecycleService>(
          create: (context) {
            final socketService = context.read<SocketService>();
            final service = AppLifecycleService(
              onResume: () {
                print('App resumed - reconnecting socket');
                socketService.reconnect();
              },
              onPause: () {
                print('App paused - disconnecting socket');
                socketService.disconnect();
              },
            );
            service.initialize();
            return service;
          },
          dispose: (_, service) => service.dispose(),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
        title: 'PNG Game',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
      ),
    );
  }
}

// GoRouter configuration
final GoRouter _router = GoRouter(
  routes: [
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
      path: '/scan_qr_code',
      builder: (context, state) => const ScanQrCode(),
    ),
    GoRoute(
      path: '/random_wait_room',
      builder: (context, state) => const RandomWaitRoom(),
    ),
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
  ],
);