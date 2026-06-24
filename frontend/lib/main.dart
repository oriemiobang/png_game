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
import 'package:png_game/screens/settings_screen.dart';
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
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:png_game/firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:png_game/providers/theme_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Request FCM permissions
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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

    // Register FCM token when user logs in
    _authApiService.addListener(_onAuthChanged);
    _onAuthChanged();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint(
            'Message also contained a notification: ${message.notification}');
        Fluttertoast.showToast(
          msg: "${message.notification!.title}: ${message.notification!.body}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.blue.shade600,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    });

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
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/leaderboard',
          builder: (context, state) => const LeaderboardScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    );
  }

  void _onAuthChanged() async {
    if (_authApiService.user != null) {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _authApiService.updateFcmToken(token);
      }
    }
  }

  @override
  void dispose() {
    _authApiService.removeListener(_onAuthChanged);
    super.dispose();
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
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            routerConfig: _router,
            debugShowCheckedModeBanner: false,
            title: 'PNG Game',
            themeMode: themeProvider.themeMode,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue.shade600,
                primary: Colors.blue.shade600,
                secondary: Colors.amber.shade600,
                surface: const Color(0xFFF4F5F7),
                brightness: Brightness.light,
              ),
              scaffoldBackgroundColor: const Color(0xFFF4F5F7),
              textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
              appBarTheme: AppBarTheme(
                backgroundColor: const Color(0xFFF4F5F7),
                elevation: 0,
                iconTheme: IconThemeData(color: Colors.blueGrey.shade900),
                titleTextStyle: GoogleFonts.outfit(
                  color: Colors.blueGrey.shade900,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                brightness: Brightness.dark,
                seedColor: Colors.blue.shade600,
                primary: Colors.blue.shade400,
                secondary: Colors.amber.shade400,
                surface: const Color(0xFF1E1E1E),
              ),
              scaffoldBackgroundColor: const Color(0xFF121212),
              textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
              appBarTheme: AppBarTheme(
                backgroundColor: const Color(0xFF1E1E1E),
                elevation: 0,
                iconTheme: const IconThemeData(color: Colors.white),
                titleTextStyle: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
