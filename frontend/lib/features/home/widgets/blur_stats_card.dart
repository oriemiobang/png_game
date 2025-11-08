import 'dart:ui';
import 'package:flutter/material.dart';

class BlurStatsCard extends StatelessWidget {
  const BlurStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
        child: Container(
          padding: const EdgeInsets.all(17),
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white.withOpacity(0.7),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat('12', 'Games'),
              _divider(),
              _buildStat('12', 'Wins'),
              _divider(),
              _buildStat('67.5 %', 'Win Rate'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() => Container(
        color: Colors.grey.shade300,
        height: double.infinity,
        width: 2,
      );

  Widget _buildStat(String value, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 24, color: Colors.green)),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(fontSize: 17),),
      ],
    );
  }
}
