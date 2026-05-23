import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:png_game/classes/data.dart';
import 'package:png_game/services/socket_service.dart';
import 'package:provider/provider.dart';

class GameResultPage extends StatelessWidget {
  const GameResultPage({super.key});

  String _formatDuration(Duration duration) {
    final safeDuration = duration.isNegative ? Duration.zero : duration;
    final hours = safeDuration.inHours;
    final minutes = safeDuration.inMinutes.remainder(60);
    final seconds = safeDuration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatRoundTime(int milliseconds) {
    return _formatDuration(Duration(milliseconds: milliseconds));
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
  }

  List<Map<String, dynamic>> _roundHistory(Map<String, dynamic> gameData) {
    final history = gameData['roundHistory'];
    if (history is List) {
      return history.map((entry) => _asMap(entry)).toList();
    }
    return <Map<String, dynamic>>[];
  }

  Duration _parseDateSpan(Map<String, dynamic> gameData) {
    final createdAt = DateTime.tryParse(gameData['createdAt']?.toString() ?? '');
    final updatedAt = DateTime.tryParse(gameData['updatedAt']?.toString() ?? '');
    if (createdAt == null || updatedAt == null) {
      return Duration.zero;
    }
    return updatedAt.toUtc().difference(createdAt.toUtc());
  }

  int _roundGuesses(Map<String, dynamic> round) {
    return (round['guesses'] as num?)?.toInt() ?? 0;
  }

  int _roundTimeMs(Map<String, dynamic> round) {
    return (round['timeMs'] as num?)?.toInt() ?? 0;
  }

  int _bestRound(List<Map<String, dynamic>> rounds) {
    if (rounds.isEmpty) {
      return 1;
    }

    final best = rounds.reduce((current, next) {
      final currentGuesses = _roundGuesses(current);
      final nextGuesses = _roundGuesses(next);
      if (nextGuesses < currentGuesses) {
        return next;
      }
      if (nextGuesses > currentGuesses) {
        return current;
      }
      return _roundTimeMs(next) < _roundTimeMs(current) ? next : current;
    });

    return (best['round'] as num?)?.toInt() ?? 1;
  }

  String _winnerLabel(Map<String, dynamic> round, String? userId) {
    final winnerId = round['winnerId']?.toString();
    if (winnerId == null || winnerId.isEmpty) {
      return 'Draw';
    }
    if (userId != null && winnerId == userId) {
      return 'You';
    }
    return 'Opponent';
  }

  String _heroTitle({required bool didWin, required bool isDraw}) {
    if (isDraw) {
      return 'Draw';
    }
    return didWin ? 'Victory!' : 'Defeat';
  }

  String _heroSubtitle({required bool didWin, required bool isDraw}) {
    if (isDraw) {
      return 'The series ended evenly.';
    }
    return didWin ? 'Congratulations! You won the match!' : 'Better luck next time!';
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = context.watch<Data>();
    final gameData = _asMap(dataProvider.data);
    final resultData = _asMap(dataProvider.winner);
    final userId = dataProvider.userId;
    final roundHistory = _roundHistory(gameData);

    if (gameData.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final winnerId = resultData['winnerId']?.toString();
    final isDraw = winnerId == null || winnerId.isEmpty;
    final didWin = !isDraw && winnerId == userId;
    final isPlayer1 = gameData['player1Id']?.toString() == userId;
    final player1Wins = (gameData['player1Wins'] as num?)?.toInt() ?? 0;
    final player2Wins = (gameData['player2Wins'] as num?)?.toInt() ?? 0;
    final myScore = isPlayer1 ? player1Wins : player2Wins;
    final opponentScore = isPlayer1 ? player2Wins : player1Wins;
    final totalRounds = roundHistory.isNotEmpty
        ? roundHistory.length
        : ((gameData['maxRounds'] as num?)?.toInt() ?? 0);
    final totalGuesses = roundHistory.fold<int>(
      0,
      (sum, round) => sum + _roundGuesses(round),
    );
    final averageGuesses = totalRounds > 0 ? totalGuesses / totalRounds : 0;
    final bestRound = _bestRound(roundHistory);
    final totalTime = roundHistory.isNotEmpty
        ? Duration(
            milliseconds: roundHistory.fold<int>(
              0,
              (sum, round) => sum + _roundTimeMs(round),
            ),
          )
        : _parseDateSpan(gameData);

    final heroGradient = isDraw
        ? const LinearGradient(
            colors: [Color(0xFF64748B), Color(0xFF334155), Color(0xFF1E293B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : didWin
            ? const LinearGradient(
                colors: [Color(0xFFF5B301), Color(0xFFFFB300), Color(0xFFF97316)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFF475569), Color(0xFF334155), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              );

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 30),
                      decoration: BoxDecoration(
                        gradient: heroGradient,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(34),
                          bottomRight: Radius.circular(34),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 92,
                            height: 92,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.14),
                                  blurRadius: 18,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Icon(
                              isDraw ? Icons.handshake_outlined : Icons.emoji_events_outlined,
                              size: 48,
                              color: isDraw ? Colors.blueGrey : const Color(0xFFF59E0B),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            _heroTitle(didWin: didWin, isDraw: isDraw),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _heroSubtitle(didWin: didWin, isDraw: isDraw),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.92),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -22),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Card(
                          elevation: 10,
                          shadowColor: Colors.black.withValues(alpha: 0.16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                const Text(
                                  'Final Score',
                                  style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text(
                                            '$myScore',
                                            style: const TextStyle(
                                              fontSize: 34,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF0F172A),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'You',
                                            style: TextStyle(
                                              color: Colors.grey.shade500,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 8),
                                      child: Text(
                                        '-',
                                        style: TextStyle(
                                          fontSize: 28,
                                          color: Color(0xFFCBD5E1),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text(
                                            '$opponentScore',
                                            style: const TextStyle(
                                              fontSize: 34,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF0F172A),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Opponent',
                                            style: TextStyle(
                                              color: Colors.grey.shade500,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Divider(color: Colors.grey.shade200, height: 1),
                                const SizedBox(height: 12),
                                _metricRow(
                                  icon: Icons.emoji_events_outlined,
                                  label: 'Total Rounds',
                                  value: '$totalRounds',
                                ),
                                _metricRow(
                                  icon: Icons.track_changes_outlined,
                                  label: 'Avg. Guesses',
                                  value: averageGuesses.toStringAsFixed(1),
                                ),
                                _metricRow(
                                  icon: Icons.access_time_outlined,
                                  label: 'Total Time',
                                  value: _formatDuration(totalTime),
                                ),
                                _metricRow(
                                  icon: Icons.trending_up_outlined,
                                  label: 'Best Round',
                                  valueWidget: _SmallBadge(
                                    text: 'Round $bestRound',
                                    background: const Color(0xFF22C55E),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Round by Round',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: roundHistory.isEmpty
                            ? [
                                _RoundTile(
                                  round: 1,
                                  isWinner: didWin,
                                  winnerLabel: isDraw ? 'Draw' : (didWin ? 'You' : 'Opponent'),
                                  guesses: totalGuesses,
                                  time: _formatDuration(totalTime),
                                  roundNumberColor: didWin ? const Color(0xFF22C55E) : const Color(0xFF94A3B8),
                                ),
                              ]
                            : roundHistory.map((round) {
                                final winnerLabel = _winnerLabel(round, userId);
                                final roundNumber = (round['round'] as num?)?.toInt() ?? 1;
                                final guesses = _roundGuesses(round);
                                final time = _formatRoundTime(_roundTimeMs(round));
                                final isWinner = winnerLabel == 'You';
                                final background = isWinner
                                    ? const Color(0xFFEAFBF1)
                                    : const Color(0xFFF8FAFC);
                                final border = isWinner
                                    ? const Color(0xFF86EFAC)
                                    : const Color(0xFFE2E8F0);
                                final roundNumberColor = isWinner
                                    ? const Color(0xFF22C55E)
                                    : const Color(0xFFCBD5E1);

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _RoundTile(
                                    round: roundNumber,
                                    isWinner: isWinner,
                                    winnerLabel: winnerLabel,
                                    guesses: guesses,
                                    time: time,
                                    roundNumberColor: roundNumberColor,
                                    background: background,
                                    borderColor: border,
                                  ),
                                );
                              }).toList(),
                      ),
                    ),
                    const SizedBox(height: 92),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2F56F6),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          context.go('/create_game');
                        },
                        child: const Text(
                          'Play Again',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          context.read<SocketService>().resetJoinState();
                          dataProvider.resetMatchState();
                          context.go('/');
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.home_outlined, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Back to Home',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricRow({
    required IconData icon,
    required String label,
    String? value,
    Widget? valueWidget,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF64748B)),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          valueWidget ??
              Text(
                value ?? '-',
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
        ],
      ),
    );
  }
}

class _SmallBadge extends StatelessWidget {
  const _SmallBadge({
    required this.text,
    required this.background,
  });

  final String text;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _RoundTile extends StatelessWidget {
  const _RoundTile({
    required this.round,
    required this.isWinner,
    required this.winnerLabel,
    required this.guesses,
    required this.time,
    required this.roundNumberColor,
    this.background,
    this.borderColor,
  });

  final int round;
  final bool isWinner;
  final String winnerLabel;
  final int guesses;
  final String time;
  final Color roundNumberColor;
  final Color? background;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final tileBackground = background ?? (isWinner ? const Color(0xFFEAFBF1) : const Color(0xFFF8FAFC));
    final tileBorder = borderColor ?? (isWinner ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0));
    final numberBackground = isWinner ? const Color(0xFF22C55E) : const Color(0xFFCBD5E1);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tileBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tileBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: numberBackground,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$round',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Round $round',
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Winner: $winnerLabel',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$guesses guesses',
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                time,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
