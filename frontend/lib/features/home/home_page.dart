import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:png_game/classes/data.dart';
import 'package:png_game/features/home/widgets/user_drawer_header.dart';
import 'package:png_game/services/auth_api_service.dart';
import 'package:png_game/models/my_user.dart';
import 'package:png_game/services/socket_service.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _setupGameJoinListener();
    super.initState();
  }

  void _setupGameJoinListener() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dataProvider = Provider.of<Data>(context, listen: false);
      final socketService = Provider.of<SocketService>(context, listen: false);

      dataProvider.addListener(() {
        if (socketService.gameJoined) {
          context.go('/play_board');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<Data>(context);
    final authApi = Provider.of<AuthApiService>(context);
    final user = authApi.user;
    final socketService = Provider.of<SocketService>(context);
    final stats = authApi.stats ?? const <String, dynamic>{};

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      key: _scaffoldKey,
      appBar: _buildAppBar(),
      drawer: _buildDrawer(user, authApi),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView(
          children: [
            const Divider(),
            _buildStatsCard(stats),
            const SizedBox(height: 18),
            _buildPlayOptionsSection(socketService),
            const SizedBox(height: 15),
            _buildPlayWithFriendSection(socketService),
            const SizedBox(height: 20),
            _buildGameHistories(stats),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      forceMaterialTransparency: true,
      leadingWidth: 160,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: Row(
          children: [
            Icon(Icons.gamepad_outlined, size: 30, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'PNG',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ],
    );
  }

  Widget _buildDrawer(MyUser? user, AuthApiService authApi) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      width: 250,
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserDrawerHeader(user: user, stats: authApi.stats),
            _buildDrawerItem(
              icon: Icons.home,
              title: 'Home',
              onTap: () => Navigator.pop(context),
            ),
            _buildDrawerItem(
              icon: Ionicons.person_outline,
              title: 'My Profile',
              onTap: () {
                Navigator.pop(context);
                context.push('/profile');
              },
            ),
            _buildDrawerItem(
              icon: Ionicons.trophy_outline,
              title: 'Leaderboard',
              onTap: () {
                Navigator.pop(context);
                context.push('/leaderboard');
              },
            ),
            _buildDrawerItem(
              icon: Icons.settings,
              title: 'Settings',
              onTap: () {
                Navigator.pop(context);
                context.push('/settings');
              },
            ),
            _buildDrawerItem(
              icon: Icons.question_mark_outlined,
              title: 'About us',
              onTap: () => context.push('/create_game'),
            ),
            _buildDrawerItem(
              icon: Icons.thumb_up_sharp,
              title: 'Rate us',
              onTap: () {},
            ),
            if (user != null)
              _buildDrawerItem(
                icon: Icons.logout,
                title: 'Log out',
                onTap: () => authApi.logout(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 25.0),
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }

  Widget _buildStatsCard(Map<String, dynamic> stats) {
    final gamesPlayed = (stats['gamesPlayed'] ?? 0).toString();
    final wins = (stats['wins'] ?? 0).toString();
    final losses = (stats['losses'] ?? 0).toString();
    final draws = (stats['draws'] ?? 0).toString();
    final winRate = '${(stats['winRate'] ?? 0).toString()} %';
    final rating = (stats['rating'] ?? 1200).toString();
    final peakRating = (stats['ratingPeak'] ?? 1200).toString();
    final tier = stats['tier'] ?? 'Beginner';

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      height: 150,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white.withValues(alpha: 0.7),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: _buildStatItem(rating, 'Rating')),
                    Container(color: Colors.grey.shade300, width: 2, height: 48),
                    Expanded(child: _buildStatItem(peakRating, 'Peak')),
                    Container(color: Colors.grey.shade300, width: 2, height: 48),
                    Expanded(child: _buildStatItem(gamesPlayed, 'Games')),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'W/L/D: $wins/$losses/$draws   •   Win Rate: $winRate   •   Tier: $tier',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 24),
        ),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(fontSize: 17)),
      ],
    );
  }

  Widget _buildPlayOptionsSection(SocketService socketService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Play Options',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        // ── Primary: auto-matchmaking ──────────────────────────────────────
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                blurRadius: 16,
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => context.push('/find_match'),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'Play Now',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // ── Secondary: solo ────────────────────────────────────────────────
        _buildPlayButton(
          icon: Icons.play_arrow_outlined,
          text: 'Play Solo',
          onPressed: () => context.push('/play_solo'),
        ),
      ],
    );
  }

  Widget _buildPlayButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.blue,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: TextButton(
          onPressed: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayWithFriendSection(SocketService socketService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Play Private',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildFriendOption(
              icon: Icons.qr_code,
              title: 'Share Room',
              description: 'Generate a Qr for\nfriends',
              onTap: () => _createAndShareRoom(socketService),
            ),
            _buildFriendOption(
              icon: Ionicons.scan_outline,
              title: 'Scan QR, Enter Code',
              description: 'Join Via Qr or enter\ncode',
              onTap: () => context.push('/join_game'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFriendOption({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(icon, size: 50, color: Colors.green),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(description, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  void _createAndShareRoom(SocketService socketService) {
    context.push('/create_game');
  }

  Widget _buildGameHistories(Map<String, dynamic> stats) {
    final historyList = stats['matchHistory'] as List<dynamic>? ?? [];
    if (historyList.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Game History',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...historyList.map((item) {
          final history = item as Map<String, dynamic>;
          final opponentName = history['opponentName'] ?? 'Unknown';
          final opponentRating = history['opponentRating'] ?? 0;
          final outcome = history['outcome'] as String? ?? 'draw';

          Color iconColor;
          IconData iconData;
          if (outcome == 'win') {
            iconColor = Colors.green;
            iconData = Ionicons.arrow_up_circle;
          } else if (outcome == 'loss') {
            iconColor = Colors.red;
            iconData = Ionicons.arrow_down_circle;
          } else {
            iconColor = Colors.grey;
            iconData = Ionicons.remove_circle;
          }

          final isDark = Theme.of(context).brightness == Brightness.dark;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade300),
            ),
            child: ListTile(
              title: Text(opponentName, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('Rating: $opponentRating'),
              trailing: Icon(iconData, color: iconColor, size: 28),
            ),
          );
        }).toList(),
      ],
    );
  }
}