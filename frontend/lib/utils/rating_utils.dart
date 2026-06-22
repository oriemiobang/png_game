import 'package:flutter/material.dart';

class RatingUtils {
  static String getTier(int rating) {
    if (rating >= 2200) return 'Master';
    if (rating >= 1800) return 'Expert';
    if (rating >= 1400) return 'Advanced';
    if (rating >= 1000) return 'Intermediate';
    return 'Beginner';
  }

  static Color getTierColor(int rating) {
    if (rating >= 2200) return const Color(0xFFFACC15); // Yellow/Gold
    if (rating >= 1800) return const Color(0xFFF87171); // Red/Coral
    if (rating >= 1400) return const Color(0xFFA78BFA); // Purple
    if (rating >= 1000) return const Color(0xFF60A5FA); // Blue
    return const Color(0xFF9CA3AF); // Gray
  }

  static Widget buildRatingBadge(int rating, {double fontSize = 14}) {
    final color = getTierColor(rating);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, color: color, size: fontSize * 1.1),
          const SizedBox(width: 2),
          Text(
            rating.toString(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
