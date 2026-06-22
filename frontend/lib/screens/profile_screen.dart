import 'package:flutter/material.dart';
import 'package:png_game/services/auth_api_service.dart';
import 'package:provider/provider.dart';
import 'package:ionicons/ionicons.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authApi = context.watch<AuthApiService>();
    final user = authApi.user;
    final stats = authApi.stats ?? <String, dynamic>{};

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('Not logged in')),
      );
    }

    final name = user.name ?? 'Player';
    final email = user.email ?? '';
    final rating = (stats['rating'] as num?)?.toInt() ?? 1200;
    final peakRating = (stats['ratingPeak'] as num?)?.toInt() ?? 1200;
    final tier = stats['tier'] as String? ?? 'Beginner';
    final gamesPlayed = (stats['gamesPlayed'] as num?)?.toInt() ?? 0;
    final wins = (stats['wins'] as num?)?.toInt() ?? 0;
    final losses = (stats['losses'] as num?)?.toInt() ?? 0;
    final draws = (stats['draws'] as num?)?.toInt() ?? 0;
    final winRate = (stats['winRate'] as num?)?.toDouble() ?? 0.0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              padding: const EdgeInsets.only(top: 20, bottom: 30),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'P',
                      style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Ionicons.trophy, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          '$tier - $rating ELO',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Statistics',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.5,
                    children: [
                      _buildStatCard('Games Played', gamesPlayed.toString(), Ionicons.game_controller, Colors.blue),
                      _buildStatCard('Win Rate', '${winRate.toStringAsFixed(1)}%', Ionicons.pie_chart, Colors.purple),
                      _buildStatCard('Wins', wins.toString(), Ionicons.arrow_up_circle, Colors.green),
                      _buildStatCard('Losses', losses.toString(), Ionicons.arrow_down_circle, Colors.red),
                      _buildStatCard('Draws', draws.toString(), Ionicons.remove_circle, Colors.orange),
                      _buildStatCard('Peak Rating', peakRating.toString(), Ionicons.star, Colors.amber),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, MaterialColor color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.shade50),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
