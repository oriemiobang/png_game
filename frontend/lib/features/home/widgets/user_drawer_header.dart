import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:png_game/models/my_user.dart';

class UserDrawerHeader extends StatelessWidget {
  final MyUser? user;

  const UserDrawerHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: user != null
          ? Center(
              child: ListTile(
                leading: const Icon(Icons.person, size: 40),
                title: Text(
                  user!.name ?? 'Player',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
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
