import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:png_game/classes/data.dart';
import 'package:png_game/features/home/widgets/user_drawer_header.dart';
import 'package:png_game/firebase_service/auth.dart';
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
    final user = Provider.of<MyUser?>(context);
    final socketService = Provider.of<SocketService>(context);
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      key: _scaffoldKey,
      appBar: _buildAppBar(),
      drawer: _buildDrawer(user, authService),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView(
          children: [
            const Divider(),
            _buildStatsCard(),
            const SizedBox(height: 18),
            _buildGameRoomsSection(dataProvider, socketService),
            const SizedBox(height: 10),
            _buildPlayOptionsSection(socketService),
            const SizedBox(height: 15),
            _buildPlayWithFriendSection(socketService),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      forceMaterialTransparency: true,
      leadingWidth: 160,
      leading: const Padding(
        padding: EdgeInsets.only(left: 12.0),
        child: Row(
          children: [
            Icon(Icons.gamepad_outlined, size: 30, color: Colors.blue),
            SizedBox(width: 8),
            Text(
              'PNG',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
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

  Widget _buildDrawer(MyUser? user, AuthService authService) {
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
            UserDrawerHeader(user: user),
            _buildDrawerItem(
              icon: Icons.home,
              title: 'Home',
              onTap: () => Navigator.pop(context),
            ),
            _buildDrawerItem(
              icon: Icons.settings,
              title: 'Settings',
              onTap: () {},
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
                onTap: () => authService.signOut(),
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

  Widget _buildStatsCard() {
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
              color: Colors.white.withOpacity(0.7),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildStatItem('12', 'Games'),
                Container(color: Colors.grey.shade300, width: 2),
                _buildStatItem('12', 'Wins'),
                Container(color: Colors.grey.shade300, width: 2),
                _buildStatItem('67.5 %', 'Win Rate'),
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

  Widget _buildGameRoomsSection(Data dataProvider, SocketService socketService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Game Rooms',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.white,
          ),
          child: ListView.builder(
            itemCount: dataProvider.randomGames?.length,
            itemBuilder: (context, index) {
              final gameId = dataProvider.randomGames?.keys.elementAt(index);
              final gameData = dataProvider.randomGames?[gameId];
              
              return _buildGameRoomItem(gameData, socketService);
            },
          ),
        ),
        _buildSeeAllButton(),
      ],
    );
  }

  Widget _buildGameRoomItem(Map<String, dynamic>? gameData, SocketService socketService) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color.fromARGB(255, 221, 221, 221)),
      ),
      child: GestureDetector(
        onTap: () => socketService.joinRandomGames(gameData?['gameId']),
        child: const ListTile(
          leading: CircleAvatar(child: Icon(Icons.person)),
          title: Text(
            "Anonymous",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          subtitle: Text('20 min'),
        ),
      ),
    );
  }

  Widget _buildSeeAllButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () => context.push('/rooms_page'),
          child: const Text(
            'See All',
            style: TextStyle(
              fontSize: 17,
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
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
        _buildPlayButton(
          icon: Icons.play_arrow_outlined,
          text: 'Play Solo',
          onPressed: () => context.push('/play_solo'),
        ),
        const SizedBox(height: 12),
        _buildPlayButton(
          icon: Icons.add,
          text: 'Create Room',
          onPressed: () {
            socketService.createRandomGame();
            context.push('/random_wait_room');
          },
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
          'Play with a Friend',
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
    final gameId = socketService.createGame();
    context.push(
      '/create_room',
      extra: gameId,
    );
  }
}