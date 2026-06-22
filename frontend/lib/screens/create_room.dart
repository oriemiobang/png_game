import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:png_game/classes/data.dart';
import 'package:png_game/services/socket_service.dart';

class CreateRoom extends StatefulWidget {
  final String? gameId;
  const CreateRoom({super.key, this.gameId});

  @override
  State<CreateRoom> createState() => _CreateRoomState();
}

class _CreateRoomState extends State<CreateRoom>
    with SingleTickerProviderStateMixin {
  late String gameId;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  SocketService? _socketService;
  VoidCallback? _socketListener;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    gameId = widget.gameId ?? Data().gameId ?? '';

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _socketService = context.read<SocketService>();
      _socketService!.resetJoinState();
      _listenForGameJoin();
    });
  }

  @override
  void dispose() {
    final listener = _socketListener;
    final socketService = _socketService;
    if (listener != null && socketService != null) {
      socketService.removeListener(listener);
    }
    _pulseController.dispose();
    super.dispose();
  }

  void _listenForGameJoin() {
    final socketService = _socketService ?? context.read<SocketService>();

    void listener() {
      if (!mounted || _isNavigating) return;
      if (socketService.gameJoined) {
        _isNavigating = true;
        socketService.removeListener(listener);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) context.go('/play_board');
        });
      }
    }

    _socketListener = listener;
    socketService.addListener(listener);
  }

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: gameId));
    Fluttertoast.showToast(
      msg: 'Code copied to clipboard!',
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
  }

  void _shareCode() {
    Share.share('Join my PNG game room! Code: $gameId');
  }

  void _showQrCode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Scan to Join',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: 200,
          height: 200,
          child: QrImageView(
            data: gameId,
            version: QrVersions.auto,
            size: 200.0,
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  void _cancelRoom() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Room'),
        content: const Text(
          'Are you sure you want to cancel this room? It will be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Waiting'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<SocketService>().cancelGame();
              context.go('/');
            },
            child: const Text('Cancel Room',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<Data>();

    // Read actual game settings from game data if available
    final gameData = data.data;
    final maxRounds = gameData?['maxRounds'] as int? ?? 3;
    final timeLimit = gameData?['timeLimit'] as int? ?? 0;
    final isPrivate = gameData?['isPrivate'] as bool? ?? true;

    // Opponent info — set once 'playerJoined' fires
    final opponentJoined = data.opponentJoined;
    final opponentName = opponentJoined?['playerName'] as String?;
    final hasOpponent = opponentName != null;

    // Format settings labels
    final roundsLabel = 'Best of $maxRounds';
    final timeLabel =
        timeLimit == 0 ? 'No Timer' : '${timeLimit}m / turn';
    final privacyLabel = isPrivate ? 'Private' : 'Public';
    final privacyIcon =
        isPrivate ? Ionicons.lock_closed_outline : Ionicons.lock_open_outline;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Ionicons.arrow_back, color: Colors.black87),
          onPressed: () => context.go('/'),
        ),
        actions: [
          // Cancel Room button in app bar
          TextButton.icon(
            onPressed: _cancelRoom,
            icon: const Icon(Icons.cancel_outlined,
                color: Colors.red, size: 18),
            label: const Text('Cancel Room',
                style: TextStyle(
                    color: Colors.red, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        width: double.infinity,
        color: Colors.blueGrey.shade50,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // ── Animated waiting icon ──────────────────────────────────
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    hasOpponent ? Ionicons.checkmark_circle : Ionicons.time,
                    size: 40,
                    color: hasOpponent
                        ? Colors.green.shade600
                        : Colors.blue.shade600,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                hasOpponent ? 'Opponent Found!' : 'Waiting for opponent...',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                hasOpponent
                    ? 'Starting game…'
                    : 'Share the code below with your friend',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 40),

              // ── Room Code Card — only shown for private rooms ──────────
              if (isPrivate) ...[
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'ROOM CODE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade500,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                gameId,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            onPressed: _copyCode,
                            icon: Icon(Ionicons.copy_outline,
                                color: Colors.blue.shade600, size: 22),
                            tooltip: 'Copy Code',
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            onPressed: _showQrCode,
                            icon: Icon(Ionicons.qr_code_outline,
                                color: Colors.blue.shade600, size: 22),
                            tooltip: 'Show QR Code',
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _shareCode,
                          icon: const Icon(Ionicons.share_social,
                              color: Colors.white),
                          label: const Text('Share Code',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // ── Players List ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PLAYERS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade500,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPlayerRow(name: 'You (Host)', isHost: true),
                    const SizedBox(height: 12),
                    _buildPlayerRow(
                      name: hasOpponent ? opponentName : 'Waiting...',
                      isHost: false,
                      isEmpty: !hasOpponent,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // ── Game Settings Footer — live data ──────────────────────
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border:
                      Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSettingItem(Ionicons.trophy_outline, roundsLabel),
                    Container(
                        width: 1, height: 40, color: Colors.grey.shade300),
                    _buildSettingItem(Ionicons.time_outline, timeLabel),
                    Container(
                        width: 1, height: 40, color: Colors.grey.shade300),
                    _buildSettingItem(privacyIcon, privacyLabel),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerRow(
      {required String name, required bool isHost, bool isEmpty = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isEmpty ? Colors.white.withValues(alpha: 0.5) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isEmpty
            ? Border.all(
                color: Colors.grey.shade300, style: BorderStyle.solid)
            : null,
        boxShadow: isEmpty
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color:
                  isEmpty ? Colors.grey.shade100 : Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isEmpty ? Ionicons.person_outline : Ionicons.person,
              color: isEmpty
                  ? Colors.grey.shade400
                  : Colors.blue.shade600,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            name,
            style: TextStyle(
              fontSize: 16,
              fontWeight:
                  isEmpty ? FontWeight.normal : FontWeight.w600,
              color:
                  isEmpty ? Colors.grey.shade500 : Colors.black87,
              fontStyle:
                  isEmpty ? FontStyle.italic : FontStyle.normal,
            ),
          ),
          if (isHost) ...[
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(8)),
              child: Text(
                'HOST',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade800),
              ),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 20),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
