import re

file_path = r'lib\screens\game_result_page.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Add _RatingChangeAnimation widget at the end
rating_widget = '''
class _RatingChangeAnimation extends StatefulWidget {
  final int oldRating;
  final int delta;
  const _RatingChangeAnimation({required this.oldRating, required this.delta});

  @override
  State<_RatingChangeAnimation> createState() => _RatingChangeAnimationState();
}

class _RatingChangeAnimationState extends State<_RatingChangeAnimation> {
  @override
  Widget build(BuildContext context) {
    final newRating = widget.oldRating + widget.delta;
    final isPositive = widget.delta >= 0;
    final color = isPositive ? Colors.green : Colors.red;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final currentRating = widget.oldRating + (widget.delta * value).round();
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '\',
              style: const TextStyle(fontSize: 18, color: Colors.grey, decoration: TextDecoration.lineThrough),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, color: Colors.grey, size: 16),
            const SizedBox(width: 8),
            Text(
              '\',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(width: 8),
            Text(
              '(\\)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color.withOpacity(value)),
            ),
          ],
        );
      },
    );
  }
}
'''

if '_RatingChangeAnimation' not in content:
    content += '\n' + rating_widget

var_insertion = '''    final ratingChanges = resultData['ratingChanges'] ?? <String, dynamic>{};
    final ratingDelta = isPlayer1 
      ? (ratingChanges['ratingChangeA'] as num?)?.toInt() ?? 0
      : (ratingChanges['ratingChangeB'] as num?)?.toInt() ?? 0;
    final myPlayerObj = isPlayer1 ? gameData['player1'] : gameData['player2'];
    final myNewRating = (myPlayerObj?['rating'] as num?)?.toInt() ?? 1200;
    final myOldRating = myNewRating - ratingDelta;

    final bestRound = _bestRound(roundHistory);'''

content = content.replace('    final bestRound = _bestRound(roundHistory);', var_insertion)

rating_card = '''                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (ratingDelta != 0 || true) ...[
                      Transform.translate(
                        offset: const Offset(0, -10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Card(
                            elevation: 10,
                            shadowColor: Colors.black.withOpacity(0.16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  const Text(
                                    'Rating Change',
                                    style: TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _RatingChangeAnimation(
                                    oldRating: myOldRating,
                                    delta: ratingDelta,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                    Transform.translate(
                      offset: const Offset(0, 0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),'''

content = content.replace('''                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),''', rating_card)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated game_result_page.dart")
