import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:png_game/classes/data.dart';
import 'package:png_game/services/socket_service.dart';
import 'package:png_game/utils/rating_utils.dart';
import 'package:flutter/services.dart';
import 'package:png_game/services/audio_service.dart';

class PlayBoard extends StatefulWidget {
  const PlayBoard({super.key});

  @override
  State<PlayBoard> createState() => _PlayBoardState();
}

class _PlayBoardState extends State<PlayBoard> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  final TextEditingController _guessController = TextEditingController();
  final TextEditingController _secretController = TextEditingController();
  
  bool _showSecret = false;
  bool _hasSetSecret = false;
  bool _wasMyTurn = false;
  int _lastOpponentGuessCount = 0;
  
  Set<int> _eliminatedNumbers = {};

  int _player1TimeLeft = 0;
  int _player2TimeLeft = 0;
  DateTime? _turnStartedAt;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenToGameState();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pulseController.dispose();
    _guessController.dispose();
    _secretController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _listenToGameState() {
    final dataProvider = context.read<Data>();
    
    // Timer logic based on whose turn it is
    dataProvider.addListener(() {
      if (!mounted) return;
      final gameData = dataProvider.data;
      if (gameData == null) return;

      final isMyTurn = gameData['turn'] == dataProvider.userId;
      final status = gameData['status'];

      // Check if we need to show winner
      if (dataProvider.winner != null) {
        _handleGameOver(dataProvider.winner!);
        dataProvider.updateWinner(null);
      }

      // Check for opponent guesses
      final allGuesses = (gameData['guesses'] as List?) ?? [];
      final opponentGuesses = allGuesses.where((g) => g['playerId'] != dataProvider.userId).toList();
      if (opponentGuesses.length > _lastOpponentGuessCount) {
        _lastOpponentGuessCount = opponentGuesses.length;
        AudioService().playOpponentGuess();
        HapticFeedback.mediumImpact();
      }

      // Sync timers
      if (gameData['status'] == 'playing') {
        _player1TimeLeft = gameData['player1TimeLeft'] ?? 0;
        _player2TimeLeft = gameData['player2TimeLeft'] ?? 0;
        _turnStartedAt = gameData['turnStartedAt'] != null ? DateTime.parse(gameData['turnStartedAt']) : null;
        if (_timer == null || !_timer!.isActive) {
          _startTimer();
        }
      } else {
        _timer?.cancel();
      }

      // Show "Your turn!" toast when it becomes your turn
      if (isMyTurn && !_wasMyTurn && status == 'playing') {
        Fluttertoast.showToast(
          msg: '⚡ Your turn!',
          backgroundColor: const Color(0xFF1E40AF),
          textColor: Colors.white,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
        );
      }
      _wasMyTurn = isMyTurn;

      // Check if last chance
      if (dataProvider.lastChance != null) {
        _handleLastChance(dataProvider.lastChance!);
        dataProvider.updateLastChance(null);
      }
    });
  }

  void _handleGameOver(Map winnerData) {
    final dataProvider = context.read<Data>();
    final userId = dataProvider.userId;
    final gameData = dataProvider.data;
    final isPlayer1 = gameData?['player1Id'] == userId;

    int myRatingChange = 0;
    if (winnerData['ratingChanges'] != null) {
      myRatingChange = isPlayer1 
          ? (winnerData['ratingChanges']['ratingChangeA'] ?? 0)
          : (winnerData['ratingChanges']['ratingChangeB'] ?? 0);
    }

    final isMatchOver = winnerData['isMatchOver'] == true;
    String title = isMatchOver ? "Series Over!" : "Round Over!";
    String message = winnerData['message'] ?? "It's a draw!";
    
    if (winnerData['winnerId'] == userId) {
      title = "Congratulations!";
      message = isMatchOver ? "You won the series!" : "You won the round!";
    } else if (winnerData['winnerId'] != null) {
      title = isMatchOver ? "Series Over!" : "Round Over!";
      message = "Sorry! You lost. Better luck next time.";
    } else {
      title = "Draw!";
      message = "It's a draw!";
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            if (myRatingChange != 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: myRatingChange > 0 ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: myRatingChange > 0 ? Colors.green.shade200 : Colors.red.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      myRatingChange > 0 ? '+$myRatingChange' : '$myRatingChange',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: myRatingChange > 0 ? Colors.green.shade700 : Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      myRatingChange > 0 ? Icons.trending_up : Icons.trending_down,
                      color: myRatingChange > 0 ? Colors.green.shade700 : Colors.red.shade700,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (isMatchOver)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () {
                  context.go('/');
                },
                child: const Text('Back to Home', style: TextStyle(color: Colors.white)),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () {
                  // Request next round
                  context.read<SocketService>().requestNewGame(userId, gameData?['id'], false);
                  Navigator.pop(context);
                },
                child: const Text('Next Round', style: TextStyle(color: Colors.white)),
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
        title: const Text("Last Chance!", textAlign: TextAlign.center, style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
        content: Text(
          isMyLastChance 
            ? 'Your opponent guessed correctly! This is your last chance to draw the game.'
            : 'You guessed correctly! Your opponent has a last chance to draw the game.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      ),
    );
  }

  void _submitSecret() {
    final secret = _secretController.text;
    if (secret.length == 4 && RegExp(r'^\d+$').hasMatch(secret) && secret.split('').toSet().length == 4) {
      context.read<SocketService>().submitSecret(secret);
      setState(() => _hasSetSecret = true);
    } else {
      Fluttertoast.showToast(msg: "Please enter a valid 4-digit unique number", backgroundColor: Colors.red);
    }
  }

  void _submitGuess() {
    final guess = _guessController.text;
    final dataProvider = context.read<Data>();
    
    if (dataProvider.data?['turn'] != dataProvider.userId) {
      Fluttertoast.showToast(msg: "Please wait for your turn!", backgroundColor: Colors.orange);
      return;
    }

    if (guess.length == 4 && RegExp(r'^\d+$').hasMatch(guess) && guess.split('').toSet().length == 4) {
      HapticFeedback.lightImpact();
      AudioService().playSubmit();
      context.read<SocketService>().sendGuess(guess);
      _guessController.clear();
    } else {
      HapticFeedback.vibrate();
      Fluttertoast.showToast(msg: "Invalid guess! Must be 4 unique digits.", backgroundColor: Colors.red);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      final dataProvider = context.read<Data>();
      final gameData = dataProvider.data;
      if (gameData == null || gameData['status'] != 'playing' || (gameData['timeLimit'] ?? 0) <= 0) {
        timer.cancel();
        return;
      }

      final now = DateTime.now().toUtc();
      final turnStart = _turnStartedAt ?? now;
      final elapsed = now.difference(turnStart).inMilliseconds;

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
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              const Text('Eliminate Numbers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Tap numbers to mark them as eliminated', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
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
                        color: isEliminated ? Colors.grey.shade200 : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isEliminated ? Colors.grey.shade300 : Colors.blue.shade200,
                          width: isEliminated ? 1 : 2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$index',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isEliminated ? Colors.grey.shade400 : Colors.blue.shade700,
                          decoration: isEliminated ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
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

    final isMyTurn = gameData['turn'] == userId;
    final status = gameData['status'];
    
    // Check if secrets are submitted by checking the backend state
    // In our NestJS backend, if player1Id == userId, we check player1Secret
    final isPlayer1 = gameData['player1Id'] == userId;
    final mySecretBackend = isPlayer1 ? gameData['player1Secret'] : gameData['player2Secret'];
    final _backendHasSecret = mySecretBackend != null;

    final opponentId = isPlayer1 ? gameData['player2Id'] : gameData['player1Id'];
    final bool hasTimer = (gameData['timeLimit'] ?? 0) > 0;
    
    final myPlayerObj = isPlayer1 ? gameData['player1'] : gameData['player2'];
    final opponentPlayerObj = isPlayer1 ? gameData['player2'] : gameData['player1'];
    final int myRating = myPlayerObj?['rating'] ?? 1200;
    final int opponentRating = opponentPlayerObj?['rating'] ?? 1200;
    final bool opponentDisconnected = dataProvider.opponentDisconnected;

    // Filter Guesses
    final allGuesses = (gameData['guesses'] as List?) ?? [];
    final myGuesses = allGuesses.where((g) => g['playerId'] == userId).toList();
    final opponentGuesses = allGuesses.where((g) => g['playerId'] != userId).toList();

    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Ionicons.close, color: Colors.black87),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Leave Game?'),
                content: const Text('Are you sure you want to forfeit this game?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                  TextButton(
                    onPressed: () {
                      context.read<SocketService>().forfeitGame();
                      Navigator.pop(context);
                      context.go('/');
                    },
                    child: const Text('Leave', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: status == 'playing' 
                  ? (isMyTurn ? Colors.green.shade50 : Colors.orange.shade50)
                  : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: status == 'playing' 
                    ? (isMyTurn ? Colors.green.shade200 : Colors.orange.shade200)
                    : Colors.blue.shade200,
                )
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    status == 'waiting' ? Ionicons.time : (isMyTurn ? Ionicons.play : Ionicons.pause),
                    size: 14,
                    color: status == 'playing' 
                      ? (isMyTurn ? Colors.green.shade700 : Colors.orange.shade700)
                      : Colors.blue.shade700,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    status == 'waiting' ? 'Setting Secrets' : (isMyTurn ? 'YOUR TURN' : 'OPPONENT\'S TURN'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: status == 'playing' 
                        ? (isMyTurn ? Colors.green.shade700 : Colors.orange.shade700)
                        : Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Consumer<Data>(
            builder: (context, data, child) {
              return IconButton(
                icon: Badge(
                  isLabelVisible: data.unreadMessages > 0,
                  label: Text('${data.unreadMessages}', style: const TextStyle(color: Colors.white, fontSize: 10)),
                  backgroundColor: Colors.red,
                  child: const Icon(Ionicons.chatbubble_ellipses_outline),
                ),
                onPressed: () {
                  // Open Chat
                  context.push('/chat');
                },
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          if (opponentDisconnected)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.red.shade600,
              child: const Text(
                'Opponent Disconnected. Waiting for them to rejoin (60s)...',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          // Top Info Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.blue.shade100,
                      child: Text((myPlayerObj?['name'] as String?)?.substring(0, 1).toUpperCase() ?? 'Y', style: TextStyle(fontSize: 10, color: Colors.blue.shade800, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 6),
                    Text('You', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    RatingUtils.buildRatingBadge(myRating, fontSize: 10),
                    const SizedBox(width: 8),
                    if (status == 'playing' && hasTimer) _buildTimerBadge(isPlayer1 ? _player1TimeLeft : _player2TimeLeft, isMyTurn),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                  child: Text('Round ${myGuesses.length + 1}/${gameData['maxRounds']}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                ),
                Row(
                  children: [
                    if (status == 'playing' && hasTimer) _buildTimerBadge(isPlayer1 ? _player2TimeLeft : _player1TimeLeft, !isMyTurn),
                    const SizedBox(width: 8),
                    RatingUtils.buildRatingBadge(opponentRating, fontSize: 10),
                    const SizedBox(width: 8),
                    Text(opponentPlayerObj?['name'] ?? 'Opponent', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                    const SizedBox(width: 6),
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.red.shade100,
                      child: Text((opponentPlayerObj?['name'] as String?)?.substring(0, 1).toUpperCase() ?? 'O', style: TextStyle(fontSize: 10, color: Colors.red.shade800, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (!_backendHasSecret) ...[
            // Set Secret Phase
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                        child: Icon(Ionicons.lock_closed, size: 48, color: Colors.blue.shade600),
                      ),
                      const SizedBox(height: 24),
                      const Text('Set Your Secret Code', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Enter a 4-digit number with no repeating digits.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
                      const SizedBox(height: 32),
                      TextField(
                        controller: _secretController,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        textAlign: TextAlign.center,
                        obscureText: !_showSecret,
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 8),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          suffixIcon: IconButton(
                            icon: Icon(_showSecret ? Ionicons.eye_off : Ionicons.eye),
                            onPressed: () => setState(() => _showSecret = !_showSecret),
                          )
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _submitSecret,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('Lock In Secret', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ] else if (status == 'waiting') ...[
            // Waiting for Opponent to set secret
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 24),
                    const Text('Waiting for opponent...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('They are setting their secret code.', style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              ),
            )
          ] else ...[
            // Playing Phase
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                indicatorColor: Colors.blue.shade600,
                labelColor: Colors.blue.shade700,
                unselectedLabelColor: Colors.grey.shade500,
                tabs: const [
                  Tab(text: 'My Guesses'),
                  Tab(text: 'Opponent\'s Guesses'),
                ],
              ),
            ),
            
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // My Guesses Tab
                  _buildGuessesList(myGuesses, true),
                  // Opponent Guesses Tab
                  _buildGuessesList(opponentGuesses, false),
                ],
              ),
            ),

            // Input Area
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AnimatedOpacity(
                            opacity: isMyTurn ? 1.0 : 0.4,
                            duration: const Duration(milliseconds: 300),
                            child: AbsorbPointer(
                              absorbing: !isMyTurn,
                              child: TextField(
                                controller: _guessController,
                                keyboardType: TextInputType.number,
                                maxLength: 4,
                                style: const TextStyle(fontSize: 20, letterSpacing: 4, fontWeight: FontWeight.bold),
                                decoration: InputDecoration(
                                  counterText: '',
                                  hintText: isMyTurn ? 'Enter guess...' : 'Waiting for opponent...',
                                  hintStyle: const TextStyle(fontSize: 16, letterSpacing: 0, fontWeight: FontWeight.normal),
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        AnimatedOpacity(
                          opacity: isMyTurn ? 1.0 : 0.35,
                          duration: const Duration(milliseconds: 300),
                          child: SizedBox(
                            width: 60,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: isMyTurn ? _submitGuess : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade600,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: const Icon(Ionicons.send, color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: _showNumberEliminator,
                          icon: Icon(Ionicons.calculator, color: Colors.grey.shade700),
                          label: Text('Scratchpad', style: TextStyle(color: Colors.grey.shade700)),
                          style: TextButton.styleFrom(backgroundColor: Colors.grey.shade100, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildGuessesList(List guesses, bool isMine) {
    if (guesses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Ionicons.document_text_outline, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(isMine ? 'Make your first guess!' : 'Waiting for opponent...', style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: guesses.length,
      itemBuilder: (context, index) {
        final guess = guesses[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text('${index + 1}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade600, fontSize: 12)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildWordleRow(guess),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWordleRow(Map guess) {
    final digits = guess['guess'].toString().split('');
    final colorFeedback = guess['colorFeedback'] as List? ?? [];
    final position = guess['position'] as int? ?? 0;
    final number = guess['number'] as int? ?? 0;

    return Row(
      children: [
        ...List.generate(4, (i) {
          final digit = i < digits.length ? digits[i] : '?';
          
          Color bg = Colors.grey.shade100;
          Color border = Colors.grey.shade300;
          Color text = Colors.grey.shade600;
          
          return Container(
            margin: const EdgeInsets.only(right: 6),
            width: 40,
            height: 44,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: border, width: 2),
            ),
            alignment: Alignment.center,
            child: Text(digit, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: text)),
          );
        }),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('P: $position', style: TextStyle(fontSize: 11, color: Colors.green.shade700, fontWeight: FontWeight.bold)),
            Text('N: $number', style: TextStyle(fontSize: 11, color: Colors.orange.shade700, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildFeedbackBadge(String label, String value, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.shade200),
      ),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: color.shade700, fontSize: 12)),
          const SizedBox(width: 6),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color.shade900, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildTimerBadge(int timeMs, bool isActive) {
    int totalSeconds = timeMs ~/ 1000;
    int m = totalSeconds ~/ 60;
    int s = totalSeconds % 60;
    String timeString = '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';

    bool isUrgent = isActive && totalSeconds < 30;
    bool flashRed = isUrgent && (totalSeconds % 2 == 0);

    Color bgColor = flashRed 
        ? Colors.red.shade100 
        : (isActive ? Colors.amber.shade100 : Colors.grey.shade100);
        
    Color borderColor = flashRed 
        ? Colors.red.shade400 
        : (isActive ? Colors.amber.shade400 : Colors.grey.shade300);
        
    Color textColor = flashRed 
        ? Colors.red.shade900 
        : (isActive ? Colors.amber.shade900 : Colors.grey.shade600);

    final badge = AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor)
      ),
      child: Text(timeString, style: TextStyle(
        fontWeight: FontWeight.bold,
        color: textColor
      )),
    );

    // Pulse the badge when it's the active player's timer
    if (isActive) {
      return ScaleTransition(scale: _pulseAnim, child: badge);
    }
    return badge;
  }
}
