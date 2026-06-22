import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:png_game/models/my_user.dart';
import 'package:png_game/utils/rating_utils.dart';

class UserDrawerHeader extends StatelessWidget {
  final MyUser? user;
  final Map<String, dynamic>? stats;

  const UserDrawerHeader({super.key, required this.user, this.stats});

  @override
  Widget build(BuildContext context) {
    final rating = stats?['rating'] ?? 1200;

    return SizedBox(
      height: 150,
      child: user != null
          ? Center(
              child: ListTile(
                leading: const Icon(Icons.person, size: 40),
                title: Row(
                  children: [
                    Text(
                      user!.name ?? 'Player',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (stats != null) RatingUtils.buildRatingBadge(rating, fontSize: 12),
                  ],
                ),
                subtitle: user!.email != null ? Text(user!.email!) : null,
              ),
            )
          : _buildLoginPrompt(context),
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/signin'),
      splashColor: Colors.grey.withOpacity(0.3),
      highlightColor: Colors.grey.withOpacity(0.3),
      child: const DrawerHeader(
        decoration: BoxDecoration(),
        child: Row(
          children: [
            Icon(
              Icons.account_circle_rounded,
              size: 60,
              color: Colors.black54,
            ),
            SizedBox(width: 10),
            Text(
              'login or register',
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
