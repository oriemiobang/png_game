import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:png_game/classes/data.dart';
import 'package:png_game/services/socket_service.dart';

class FindMatchScreen extends StatefulWidget {
  const FindMatchScreen({super.key});

  @override
  State<FindMatchScreen> createState() => _FindMatchScreenState();
}

class _FindMatchScreenState extends State<FindMatchScreen>
    with TickerProviderStateMixin {
  // ── Settings ──────────────────────────────────────────────────────────────
  int _maxRounds = 3;
  int _timeLimit = 3; // minutes (0 = off)

  // ── Animation ─────────────────────────────────────────────────────────────
  late final AnimationController _pulseCtrl;
  late final AnimationController _rotateCtrl;
  late final Animation<double> _pulse;
  late final Animation<double> _rotate;

  // ── State ─────────────────────────────────────────────────────────────────
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _pulse = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _rotate = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotateCtrl, curve: Curves.linear),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenForMatch();
    });
  }

  @override
  void dispose() {
    final data = context.read<Data>();
    data.removeListener(_onDataChange);
    _pulseCtrl.dispose();
    _rotateCtrl.dispose();
    super.dispose();
  }

  void _listenForMatch() {
    context.read<Data>().addListener(_onDataChange);
  }

  void _onDataChange() {
    if (!mounted || _isNavigating) return;
    final data = context.read<Data>();

    if (data.matchFoundData != null && data.gameId != null) {
      _isNavigating = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/play_board');
      });
      return;
    }

    if (data.matchmakingTimedOut) {
      _showTimeoutSnackbar();
    }
  }

  void _showTimeoutSnackbar() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: const Row(
          children: [
            Icon(Ionicons.time_outline, color: Colors.amber, size: 18),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'No opponent found. Please try again.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startSearch() {
    context.read<SocketService>().findMatch(
          maxRounds: _maxRounds,
          timeLimit: _timeLimit,
        );
  }

  void _cancelSearch() {
    context.read<SocketService>().cancelMatchmaking();
  }

  String _timeLimitLabel(int mins) {
    if (mins == 0) return 'No Timer';
    return '$mins min';
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<Data>();
    final isSearching = data.isSearchingForMatch;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // ── Decorative background blobs ───────────────────────────────────
          Positioned(
            top: -80,
            right: -80,
            child: _GlowCircle(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                size: 300),
          ),
          Positioned(
            bottom: -60,
            left: -60,
            child: _GlowCircle(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.10),
                size: 240),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── App bar ──────────────────────────────────────────────
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Ionicons.arrow_back,
                            color: Colors.white70),
                        onPressed: () {
                          if (isSearching) _cancelSearch();
                          context.go('/');
                        },
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Find Match',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // ── Animated icon ───────────────────────────────
                        AnimatedBuilder(
                          animation:
                              Listenable.merge([_pulseCtrl, _rotateCtrl]),
                          builder: (context, _) {
                            return ScaleTransition(
                              scale: _pulse,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF3B82F6),
                                      Color(0xFF8B5CF6)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF3B82F6)
                                          .withValues(alpha: 0.4),
                                      blurRadius: 32,
                                      spreadRadius: 8,
                                    ),
                                  ],
                                ),
                                child: isSearching
                                    ? Transform.rotate(
                                        angle: _rotate.value,
                                        child: const Icon(
                                          Ionicons.reload_outline,
                                          color: Colors.white,
                                          size: 52,
                                        ),
                                      )
                                    : const Icon(
                                        Ionicons.game_controller_outline,
                                        color: Colors.white,
                                        size: 52,
                                      ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // ── Title area ──────────────────────────────────
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: isSearching
                              ? Column(
                                  key: const ValueKey('searching'),
                                  children: [
                                    const Text(
                                      'Searching for opponent…',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '$_maxRounds rounds  •  ${_timeLimitLabel(_timeLimit)}',
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                )
                              : const Column(
                                  key: ValueKey('idle'),
                                  children: [
                                    Text(
                                      'Play Now',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Pick your settings and we\'ll find you\nan opponent instantly.',
                                      style: TextStyle(
                                          color: Colors.white54, fontSize: 14),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                        ),

                        const SizedBox(height: 36),

                        // ── Settings card ────────────────────────────────
                        AnimatedOpacity(
                          opacity: isSearching ? 0.4 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: IgnorePointer(
                            ignoring: isSearching,
                            child: _SettingsCard(
                              maxRounds: _maxRounds,
                              timeLimit: _timeLimit,
                              onRoundsChanged: (v) =>
                                  setState(() => _maxRounds = v),
                              onTimeLimitChanged: (v) =>
                                  setState(() => _timeLimit = v),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // ── Action button ───────────────────────────────
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: isSearching
                              ? _CancelButton(
                                  key: const ValueKey('cancel'),
                                  onPressed: _cancelSearch,
                                )
                              : _FindMatchButton(
                                  key: const ValueKey('find'),
                                  onPressed: _startSearch,
                                ),
                        ),

                        const SizedBox(height: 20),

                        // ── Private room link ───────────────────────────
                        if (!isSearching) ...[
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Colors.white.withValues(alpha: 0.12),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'or',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.4),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Colors.white.withValues(alpha: 0.12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _PrivateRoomButton(
                            onTap: () => context.go('/create_game'),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _GlowCircle extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowCircle({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final int maxRounds;
  final int timeLimit;
  final ValueChanged<int> onRoundsChanged;
  final ValueChanged<int> onTimeLimitChanged;

  const _SettingsCard({
    required this.maxRounds,
    required this.timeLimit,
    required this.onRoundsChanged,
    required this.onTimeLimitChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rounds
          _SectionLabel(icon: Ionicons.trophy_outline, label: 'Rounds'),
          const SizedBox(height: 12),
          Row(
            children: [3, 5, 7, 10]
                .map((n) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _OptionChip(
                          label: '$n',
                          selected: maxRounds == n,
                          onTap: () => onRoundsChanged(n),
                          selectedColor: const Color(0xFF3B82F6),
                        ),
                      ),
                    ))
                .toList(),
          ),

          const SizedBox(height: 22),

          // Timer
          _SectionLabel(
              icon: Ionicons.timer_outline, label: 'Timer per player'),
          const SizedBox(height: 12),
          Row(
            children: [0, 1, 3, 5, 10]
                .map((m) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: _OptionChip(
                          label: m == 0 ? 'Off' : '${m}m',
                          selected: timeLimit == m,
                          onTap: () => onTimeLimitChanged(m),
                          selectedColor: const Color(0xFFF59E0B),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white60),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _OptionChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color selectedColor;

  const _OptionChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 44,
        decoration: BoxDecoration(
          color: selected
              ? selectedColor
              : Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? selectedColor
                : Colors.white.withValues(alpha: 0.12),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: selectedColor.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white54,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _FindMatchButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _FindMatchButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Ionicons.search, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text(
                'Find Match',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CancelButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _CancelButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Ionicons.close_circle_outline,
            color: Colors.white70, size: 20),
        label: const Text(
          'Cancel Search',
          style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          side:
              BorderSide(color: Colors.white.withValues(alpha: 0.25)),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}

class _PrivateRoomButton extends StatelessWidget {
  final VoidCallback onTap;
  const _PrivateRoomButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: const Row(
          children: [
            Icon(Ionicons.lock_closed_outline,
                color: Colors.white60, size: 20),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Play with a friend',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Create a private room and share the code or QR',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Ionicons.chevron_forward,
                color: Colors.white30, size: 18),
          ],
        ),
      ),
    );
  }
}
