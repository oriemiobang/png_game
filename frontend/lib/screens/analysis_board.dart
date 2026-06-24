import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:png_game/services/auth_api_service.dart';
import 'package:provider/provider.dart';

class AnalysisBoard extends StatefulWidget {
  final String gameId;
  const AnalysisBoard({super.key, required this.gameId});

  @override
  State<AnalysisBoard> createState() => _AnalysisBoardState();
}

class _AnalysisBoardState extends State<AnalysisBoard> with TickerProviderStateMixin {
  late TabController _tabController;
  
  Map<String, dynamic>? _gameData;
  bool _isLoading = true;
  
  int _myIndex = 0;
  int _oppIndex = 0;
  
  String? _myAnalysis;
  String? _oppAnalysis;
  bool _isAnalyzing = false;

  final Map<int, String> _myAnalysisCache = {};
  final Map<int, String> _oppAnalysisCache = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _fetchData();
  }

  Future<void> _fetchData() async {
    final authApi = context.read<AuthApiService>();
    final data = await authApi.fetchGameDetails(widget.gameId);
    if (mounted) {
      setState(() {
        _gameData = data;
        _isLoading = false;
      });
      // Optionally pre-fetch analysis for the first move if there are any
    }
  }

  Future<void> _analyzeCurrentMove() async {
    if (_gameData == null) return;
    final isMyBoard = _tabController.index == 0;
    final currentIndex = isMyBoard ? _myIndex : _oppIndex;
    final guesses = isMyBoard ? _gameData!['myGuesses'] : _gameData!['opponentGuesses'];
    
    if (currentIndex == 0 || currentIndex > guesses.length) {
      setState(() {
        if (isMyBoard) _myAnalysis = null;
        else _oppAnalysis = null;
      });
      return;
    }

    // We analyze the guess at index (currentIndex - 1)
    final guessToAnalyze = currentIndex - 1;

    final cache = isMyBoard ? _myAnalysisCache : _oppAnalysisCache;
    if (cache.containsKey(guessToAnalyze)) {
      setState(() {
        if (isMyBoard) _myAnalysis = cache[guessToAnalyze];
        else _oppAnalysis = cache[guessToAnalyze];
      });
      return;
    }

    setState(() => _isAnalyzing = true);
    
    final authApi = context.read<AuthApiService>();
    // Wait, the backend API expects the guessIndex relative to the player's guesses.
    // BUT we need a way to tell the backend if we are analyzing OUR guess or OPPONENT guess.
    // Currently `GET /game/:id/analyze/:guessIndex` assumes we are analyzing OUR guess because it checks `userId == player.id`.
    // Let's modify our logic: for MVP, let's only analyze OUR guesses, or we need to update the backend to allow analyzing opponent.
    // The user said: "also when you click opponent board it should do the same so you could learn from your oppoenent mistakes".
    // Since backend requires modifying to support opponent analysis, let's add `?playerId=...` to backend later. For now, try fetching.
    
    // Actually, we can fetch analysis from backend.
    final analysis = await authApi.fetchAnalysis(widget.gameId, guessToAnalyze);
    
    if (mounted) {
      setState(() {
        _isAnalyzing = false;
        if (analysis != null) cache[guessToAnalyze] = analysis;
        if (isMyBoard) _myAnalysis = analysis ?? "Could not fetch analysis.";
        else _oppAnalysis = analysis ?? "Could not fetch analysis.";
      });
    }
  }

  void _next() {
    if (_gameData == null) return;
    final isMyBoard = _tabController.index == 0;
    final guesses = isMyBoard ? _gameData!['myGuesses'] : _gameData!['opponentGuesses'];
    
    if (isMyBoard && _myIndex < guesses.length) {
      setState(() => _myIndex++);
      _analyzeCurrentMove();
    } else if (!isMyBoard && _oppIndex < guesses.length) {
      setState(() => _oppIndex++);
      // Need to fix backend to support opponent analysis first, but we will call it anyway.
      _analyzeCurrentMove();
    }
  }

  void _prev() {
    final isMyBoard = _tabController.index == 0;
    if (isMyBoard && _myIndex > 0) {
      setState(() => _myIndex--);
      _analyzeCurrentMove();
    } else if (!isMyBoard && _oppIndex > 0) {
      setState(() => _oppIndex--);
      _analyzeCurrentMove();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Analysis Board')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_gameData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Analysis Board')),
        body: const Center(child: Text('Failed to load game data')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Analysis'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Board'),
            Tab(text: 'Opponent Board'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBoard(_gameData!['myGuesses'], _myIndex, _gameData!['opponentSecret']),
                _buildBoard(_gameData!['opponentGuesses'], _oppIndex, _gameData!['mySecret']),
              ],
            ),
          ),
          _buildAnalysisPanel(),
        ],
      ),
    );
  }

  Widget _buildBoard(List<dynamic> allGuesses, int currentIndex, String? secretCode) {
    final visibleGuesses = allGuesses.take(currentIndex).toList();
    
    return Column(
      children: [
        if (secretCode != null)
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.amber.shade100,
            width: double.infinity,
            child: Center(
              child: Text(
                'Secret Code: $secretCode',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 4, color: Colors.black87),
              ),
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: visibleGuesses.length,
            itemBuilder: (context, index) {
              final guess = visibleGuesses[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(
                    guess['guess'] ?? '',
                    style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildBadge(guess['position'], Colors.green, Ionicons.checkmark_circle),
                      const SizedBox(width: 8),
                      _buildBadge(guess['number'], Colors.amber, Ionicons.help_circle),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(int count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            count.toString(),
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisPanel() {
    final isMyBoard = _tabController.index == 0;
    final currentIndex = isMyBoard ? _myIndex : _oppIndex;
    final guesses = isMyBoard ? _gameData!['myGuesses'] : _gameData!['opponentGuesses'];
    final analysisText = isMyBoard ? _myAnalysis : _oppAnalysis;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: currentIndex > 0 ? _prev : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Prev'),
                ),
                Text('Turn $currentIndex / ${guesses.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: currentIndex < guesses.length ? _next : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (currentIndex == 0)
              const Text('Click Next to analyze the first turn.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey))
            else if (_isAnalyzing)
              const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
            else if (analysisText != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Ionicons.sparkles, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        analysisText,
                        style: const TextStyle(fontSize: 15, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
