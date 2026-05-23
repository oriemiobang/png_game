import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:png_game/classes/data.dart';
import 'package:png_game/services/socket_service.dart';

class PlayBoard extends StatefulWidget {
  const PlayBoard({super.key});

  @override
  State<PlayBoard> createState() => _PlayBoardState();
}

class _PlayBoardState extends State<PlayBoard>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final VoidCallback _gameStateListener;

  final TextEditingController _guessController = TextEditingController();
  final TextEditingController _secretController = TextEditingController();

  bool _showSecret = false;
  bool _hasSetSecret = false;
  bool _listenerAttached = false;

  Set<int> _eliminatedNumbers = {};

  int _player1TimeLeft = 0;
  int _player2TimeLeft = 0;
  DateTime? _lastMoveAt;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _gameStateListener = _handleGameStateUpdate;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _listenerAttached) return;
      Data().addListener(_gameStateListener);
      _listenerAttached = true;
      _handleGameStateUpdate();
    });
  }

  @override
  void dispose() {
    if (_listenerAttached) {
      Data().removeListener(_gameStateListener);
    }
    _tabController.dispose();
    _guessController.dispose();
    _secretController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _handleGameStateUpdate() {
    if (!mounted) return;

    final dataProvider = Data();
    final gameData = dataProvider.data;
    if (gameData == null) return;

    if (dataProvider.winner != null) {
      _handleGameOver(dataProvider.winner!);
      dataProvider.updateWinner(null);
    }

    if (gameData['status'] == 'playing') {
      _player1TimeLeft = (gameData['player1TimeLeft'] ?? 0) as int;
      _player2TimeLeft = (gameData['player2TimeLeft'] ?? 0) as int;

      final lastMove = gameData['lastMoveAt'];
      _lastMoveAt = lastMove == null ? null : DateTime.parse(lastMove.toString()).toUtc();
      _startTimer();
    } else {
      _timer?.cancel();
    }

    if (dataProvider.lastChance != null) {
      _handleLastChance(dataProvider.lastChance!);
      dataProvider.updateLastChance(null);
    }
  }

  void _handleGameOver(Map winnerData) {
    if (!mounted) return;

    final userId = context.read<Data>().userId;
    String title = 'Game Over!';
    String message = 'It\'s a draw!';

    if (winnerData['winnerId'] == userId) {
      title = 'Congratulations!';
      message = 'You won the game!';
    } else if (winnerData['winnerId'] != null) {
      title = 'Game Over!';
      message = 'Sorry! You lost. Better luck next time.';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(message, textAlign: TextAlign.center),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                context.go('/');
              },
              child: const Text(
                'Back to Home',
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _handleLastChance(Map lastChanceData) {
    final userId = context.read<Data>().userId;
    final isMyLastChance = lastChanceData['chanceTo'] == userId;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Last Chance!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          isMyLastChance
              ? 'Your opponent guessed correctly! This is your last chance to draw the game.'
              : 'You guessed correctly! Your opponent has a last chance to draw the game.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  void _submitSecret() {
    final secret = _secretController.text;
    final isValid = secret.length == 4 &&
        RegExp(r'^\d+$').hasMatch(secret) &&
        secret.split('').toSet().length == 4;

    if (isValid) {
      context.read<SocketService>().submitSecret(secret);
      setState(() => _hasSetSecret = true);
    } else {
      Fluttertoast.showToast(
        msg: 'Please enter a valid 4-digit unique number',
        backgroundColor: Colors.red,
      );
    }
  }

  void _submitGuess() {
    final guess = _guessController.text;
    final dataProvider = context.read<Data>();

    if (dataProvider.data?['turn'] != dataProvider.userId) {
      Fluttertoast.showToast(
        msg: 'Please wait for your turn!',
        backgroundColor: Colors.orange,
      );
      return;
    }

    final isValid = guess.length == 4 &&
        RegExp(r'^\d+$').hasMatch(guess) &&
        guess.split('').toSet().length == 4;

    if (isValid) {
      context.read<SocketService>().sendGuess(guess);
      _guessController.clear();
    } else {
      Fluttertoast.showToast(
        msg: 'Invalid guess! Must be 4 unique digits.',
        backgroundColor: Colors.red,
      );
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      final dataProvider = Data();
      final gameData = dataProvider.data;
      if (gameData == null ||
          gameData['status'] != 'playing' ||
          (gameData['timeLimit'] ?? 0) <= 0) {
        timer.cancel();
        return;
      }

      final now = DateTime.now().toUtc();
      final lastMove = _lastMoveAt ?? now;
      final elapsed = now.difference(lastMove).inMilliseconds;

      setState(() {
        if (gameData['turn'] == gameData['player1Id']) {
          _player1TimeLeft = (gameData['player1TimeLeft'] ?? 0) - elapsed;
          if (_player1TimeLeft <= 0) {
            _player1TimeLeft = 0;
            _handleTimeout();
          }
        } else {
          _player2TimeLeft = (gameData['player2TimeLeft'] ?? 0) - elapsed;
          if (_player2TimeLeft <= 0) {
            _player2TimeLeft = 0;
            _handleTimeout();
          }
        }
      });
    });
  }

  void _handleTimeout() {
    _timer?.cancel();
    context.read<SocketService>().reportTimeout();
  }

  void _showNumberEliminator() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Eliminate Numbers',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap numbers to mark them as eliminated',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: List.generate(10, (index) {
                  final isEliminated = _eliminatedNumbers.contains(index);
                  return GestureDetector(
                    onTap: () {
                      setModalState(() {
                        if (isEliminated) {
                          _eliminatedNumbers.remove(index);
                        } else {
                          _eliminatedNumbers.add(index);
                        }
                      });
                      setState(() {});
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color:
                            isEliminated ? Colors.grey.shade200 : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isEliminated
                              ? Colors.grey.shade300
                              : Colors.blue.shade200,
                          width: isEliminated ? 1 : 2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$index',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isEliminated
                              ? Colors.grey.shade400
                              : Colors.blue.shade700,
                          decoration:
                              isEliminated ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  int _scoreFromGuesses(List guesses) {
    return guesses.where((guess) {
      final position = guess['position'];
      final positionValue = position is int
          ? position
          : int.tryParse(position?.toString() ?? '0') ?? 0;
      return positionValue > 0;
    }).length;
  }

  int _roundNumber(List allGuesses) {
    if (allGuesses.isEmpty) return 1;
    return allGuesses.length;
  }

  String _formatTime(int timeMs) {
    final safeTime = timeMs < 0 ? 0 : timeMs;
    final totalSeconds = safeTime ~/ 1000;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  DateTime? _parseGameDate(dynamic value) {
    if (value == null) return null;
    return DateTime.parse(value.toString()).toUtc();
  }

  Widget _buildMetricItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String valueColorHex,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              height: 1,
              fontWeight: FontWeight.bold,
              color: Color(int.parse(valueColorHex)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTurnChip(bool isMyTurn, bool isPlaying) {
    final backgroundColor = !isPlaying
        ? const Color(0xFF334155)
        : isMyTurn
            ? const Color(0xFF16A34A)
            : const Color(0xFFE11D48);
    final icon = !isPlaying
        ? Ionicons.hourglass_outline
        : isMyTurn
            ? Ionicons.play
            : Ionicons.pause;
    final label = !isPlaying
        ? 'Setting Secrets'
        : isMyTurn
            ? 'Your turn'
            : 'Opponent\'s turn';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClockChip(int timeMs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Ionicons.time_outline, size: 15, color: Colors.blueGrey.shade700),
          const SizedBox(width: 6),
          Text(
            _formatTime(timeMs),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.blueGrey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatButton() {
    final unread = context.watch<Data>().unreadMessages;

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            icon: const Icon(Ionicons.chatbubble_outline, color: Colors.black87),
            onPressed: () {
              context.push('/chat');
            },
          ),
          if (unread > 0)
            Positioned(
              right: 5,
              top: 5,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$unread',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSecretBox(String value) {
    return Container(
      width: 58,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }

  Widget _buildSecretStrip(String secret, bool hidden) {
    final digits = secret.padRight(4).split('').take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            'Secret Code',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(4, (index) {
            final value = hidden ? '*' : digits[index];
            return _buildSecretBox(value);
          }),
        ),
      ],
    );
  }

  Widget _buildBoardSwitcher() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x16000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        labelColor: Colors.black87,
        unselectedLabelColor: Colors.grey.shade700,
        labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        tabs: const [
          Tab(text: 'My Board'),
          Tab(text: 'Opponent\'s Board'),
        ],
      ),
    );
  }

  Widget _buildGuessHistoryCard(List guesses) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Guess History',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                _buildTableHeader(),
                if (guesses.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    child: Text(
                      'No guesses yet',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  )
                else
                  ...guesses.asMap().entries.map((entry) {
                    final index = entry.key;
                    final guess = Map<String, dynamic>.from(entry.value as Map);
                    return _buildGuessRow(index + 1, guess);
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '#',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Guess',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          SizedBox(
            width: 54,
            child: Text(
              'P',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          SizedBox(
            width: 54,
            child: Text(
              'N',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuessRow(int index, Map<String, dynamic> guess) {
    final guessValue = guess['guess']?.toString() ?? '';
    final positionValue = guess['position']?.toString() ?? '0';
    final numberValue = guess['number']?.toString() ?? '0';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$index',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              guessValue,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.4,
              ),
            ),
          ),
          SizedBox(
            width: 54,
            child: _buildFeedbackPill(positionValue, Colors.green),
          ),
          SizedBox(
            width: 54,
            child: _buildFeedbackPill(numberValue, Colors.orange),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackPill(String value, MaterialColor color) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color.shade500,
          borderRadius: BorderRadius.circular(999),
        ),
        alignment: Alignment.center,
        child: Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildBoardContent(List guesses, String emptyText) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        children: [
          _buildGuessHistoryCard(guesses),
          const SizedBox(height: 18),
          if (guesses.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 18),
              child: Text(
                emptyText,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSecretSetupWidget() {
    return Expanded(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Ionicons.lock_closed,
                    size: 36,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Set Your Secret Code',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter a 4-digit number with no repeating digits.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _secretController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  textAlign: TextAlign.center,
                  obscureText: !_showSecret,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(_showSecret ? Ionicons.eye_off : Ionicons.eye),
                      onPressed: () => setState(() => _showSecret = !_showSecret),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _submitSecret,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Lock In Secret',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWaitingWidget() {
    return const Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              'Waiting for opponent...',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('They are setting their secret code.'),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayingContent({
    required Map<String, dynamic> gameData,
    required bool isMyTurn,
    required bool isPlayer1,
    required List myGuesses,
    required List opponentGuesses,
    required String secret,
  }) {
    final totalGuesses = (gameData['guesses'] as List?) ?? [];
    final roundNumber = _roundNumber(totalGuesses);
    final myScore = _scoreFromGuesses(myGuesses);
    final opponentScore = _scoreFromGuesses(opponentGuesses);
    final hasTimer = (gameData['timeLimit'] ?? 0) > 0;
    final activeTime = isPlayer1 ? _player1TimeLeft : _player2TimeLeft;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x10000000),
                        blurRadius: 12,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _buildMetricItem(
                        icon: Ionicons.trophy_outline,
                        iconColor: const Color(0xFFF59E0B),
                        label: 'Round',
                        value: '$roundNumber',
                        valueColorHex: '0xFF0F172A',
                      ),
                      Container(
                        width: 1,
                        height: 34,
                        color: Colors.grey.shade200,
                      ),
                      _buildMetricItem(
                        icon: Ionicons.person_circle_outline,
                        iconColor: const Color(0xFF2563EB),
                        label: 'Your Score',
                        value: '$myScore',
                        valueColorHex: '0xFF0F172A',
                      ),
                      Container(
                        width: 1,
                        height: 34,
                        color: Colors.grey.shade200,
                      ),
                      _buildMetricItem(
                        icon: Ionicons.person_circle_outline,
                        iconColor: const Color(0xFFEF4444),
                        label: 'Opponent',
                        value: '$opponentScore',
                        valueColorHex: '0xFF0F172A',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x10000000),
                        blurRadius: 12,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: _buildSecretStrip(
                    secret,
                    true,
                  ),
                ),
                const SizedBox(height: 14),
                _buildBoardSwitcher(),
                const SizedBox(height: 14),
                SizedBox(
                  height: 380,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildBoardContent(
                        myGuesses,
                        'Your guesses will appear here.',
                      ),
                      _buildBoardContent(
                        opponentGuesses,
                        'Opponent guesses will appear here.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 14,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Make Your Guess',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (hasTimer)
                      Text(
                        'Clock ${_formatTime(activeTime)}',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _guessController,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        style: const TextStyle(
                          fontSize: 18,
                          letterSpacing: 3.5,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: 'Enter 4 digits...',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            letterSpacing: 0,
                            fontWeight: FontWeight.normal,
                            color: Colors.grey.shade400,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 15,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.green.shade400,
                              width: 1.6,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isMyTurn ? _submitGuess : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7CCF97),
                          disabledBackgroundColor: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        child: const Text(
                          'Submit',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Leave Game?'),
                          content: const Text(
                            'Are you sure you want to forfeit this game?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => context.go('/'),
                              child: const Text(
                                'Leave',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Leave Game',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = context.watch<Data>();
    final gameData = dataProvider.data;
    final userId = dataProvider.userId;

    if (gameData == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final status = gameData['status'];
    final isMyTurn = gameData['turn'] == userId;
    final isPlayer1 = gameData['player1Id'] == userId;
    final opponentId = isPlayer1 ? gameData['player2Id'] : gameData['player1Id'];
    final mySecretBackend = isPlayer1 ? gameData['player1Secret'] : gameData['player2Secret'];
    final hasBackendSecret = mySecretBackend != null;
    final hasTimer = (gameData['timeLimit'] ?? 0) > 0;
    final showSecretSubmitted = _hasSetSecret || hasBackendSecret;

    final allGuesses = (gameData['guesses'] as List?) ?? [];
    final myGuesses = allGuesses.where((guess) => guess['playerId'] == userId).toList();
    final opponentGuesses = allGuesses.where((guess) => guess['playerId'] != userId).toList();

    final activeTime = isPlayer1 ? _player1TimeLeft : _player2TimeLeft;
    final turnChip = _buildTurnChip(isMyTurn, status == 'playing');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Ionicons.arrow_back, color: Colors.black87),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Leave Game?'),
                content: const Text('Are you sure you want to forfeit this game?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Leave', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
          },
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 4),
            turnChip,
            const SizedBox(width: 10),
            if (status == 'playing' && hasTimer) _buildClockChip(activeTime),
          ],
        ),
        actions: [_buildChatButton()],
      ),
      body: SafeArea(
        top: false,
        child: !showSecretSubmitted
            ? _buildSecretSetupWidget()
            : status == 'waiting'
                ? _buildWaitingWidget()
                : _buildPlayingContent(
                    gameData: Map<String, dynamic>.from(gameData),
                    isMyTurn: isMyTurn,
                    isPlayer1: isPlayer1,
                    myGuesses: myGuesses,
                    opponentGuesses: opponentGuesses,
                    secret: mySecretBackend?.toString() ?? '',
                  ),
      ),
    );
  }
}
