import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:png_game/services/auth_api_service.dart';
import 'package:ionicons/ionicons.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<dynamic>? _leaderboard;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    final authApi = context.read<AuthApiService>();
    final data = await authApi.getLeaderboard();
    if (mounted) {
      setState(() {
        _leaderboard = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Global Leaderboard', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _leaderboard == null
              ? const Center(child: Text('Failed to load leaderboard'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: _leaderboard!.length,
                  itemBuilder: (context, index) {
                    final user = _leaderboard![index];
                    return _buildLeaderboardTile(user, index);
                  },
                ),
    );
  }

  Widget _buildLeaderboardTile(Map<String, dynamic> user, int index) {
    final rank = index + 1;
    final name = user['name'] ?? 'Unknown';
    final rating = user['rating'] ?? 1200;
    final tier = user['tier'] ?? 'Beginner';
    final winRate = user['winRate'] ?? 0;

    Color rankColor = Colors.grey.shade700;
    IconData? medalIcon;

    if (rank == 1) {
      rankColor = const Color(0xFFFFD700); // Gold
      medalIcon = Ionicons.medal;
    } else if (rank == 2) {
      rankColor = const Color(0xFFC0C0C0); // Silver
      medalIcon = Ionicons.medal;
    } else if (rank == 3) {
      rankColor = const Color(0xFFCD7F32); // Bronze
      medalIcon = Ionicons.medal;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: rank <= 3 ? Border.all(color: rankColor.withValues(alpha: 0.5), width: 1.5) : Border.all(color: Colors.grey.shade100),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 30,
              child: medalIcon != null
                  ? Icon(medalIcon, color: rankColor, size: 28)
                  : Text('#$rank', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: rankColor), textAlign: TextAlign.center),
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.blue.shade50,
              child: Text(
                name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700),
              ),
            ),
          ],
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Row(
          children: [
            Text(tier, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('$winRate% WR', style: TextStyle(color: Colors.green.shade700, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text('ELO', style: TextStyle(fontSize: 10, color: Colors.grey)),
            Text(
              rating.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
