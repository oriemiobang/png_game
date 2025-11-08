import 'package:cloud_firestore/cloud_firestore.dart';
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
          ? FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('png')
                  .doc(user!.uid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text('No user data found'));
                }

                final userData = snapshot.data!.data() as Map<String, dynamic>;
                final userName = userData['userName'] ?? 'Player';

                return Center(
                  child: ListTile(
                    leading: const Icon(Icons.person, size: 40),
                    title: Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
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