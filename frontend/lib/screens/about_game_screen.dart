import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';

class AboutGameScreen extends StatelessWidget {
  const AboutGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Ionicons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'About the Game',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Ionicons.game_controller_outline,
                    size: 48, color: primaryColor),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'How to Play',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'This is a logic puzzle where players race to guess each other\'s secret 4-digit code. Use deduction, logic, and a bit of luck to crack the code before your opponent does!',
              style:
                  TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
            ),
            const SizedBox(height: 24),
            _buildRuleSection(
              title: '1. Set Your Secret',
              content:
                  'At the start of a round, both players pick a 4-digit secret number. All 4 digits must be unique (no repeating digits allowed).',
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildRuleSection(
              title: '2. Take Turns Guessing',
              content:
                  'Players take turns guessing the opponent\'s secret code. You will receive feedback after every guess.',
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            _buildRuleSection(
              title: '3. Understand Feedback',
              content:
                  'After a guess, you get two clues:\n\n• Position: How many digits are correct AND in the exact right spot.\n• Number: The total number of correct digits in your guess (regardless of position).\n\nExample: If the secret is "1234" and you guess "1547", you get:\n- Position = 1 (the \'1\' is correct)\n- Number = 2 (\'1\' and \'4\' are both in the secret)',
              color: Colors.purple,
            ),
            const SizedBox(height: 16),
            _buildRuleSection(
              title: '4. Winning the Round',
              content:
                  'To win, you must guess the secret perfectly (Position = 4). If Player 1 guesses the code first, Player 2 gets one "Last Chance" turn to force a Draw.',
              color: Colors.green,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleSection({
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
                fontSize: 14, color: Colors.grey.shade700, height: 1.5),
          ),
        ],
      ),
    );
  }
}
