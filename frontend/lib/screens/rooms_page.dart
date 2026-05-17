import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:png_game/classes/data.dart';
import 'package:png_game/services/socket_service.dart';

class GameRooms extends StatefulWidget {
  const GameRooms({super.key});

  @override
  State<GameRooms> createState() => _GameRoomsState();
}

class _GameRoomsState extends State<GameRooms> {
  String searchQuery = '';
  String activeFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final publicRooms = context.watch<Data>().publicRooms;
    final socketService = context.read<SocketService>();

    final filteredRooms = publicRooms.where((room) {
      final name = 'Room ${room['id']?.substring(0, 6) ?? ''}'.toLowerCase();
      final host = (room['player1Id'] ?? '').toString().toLowerCase();
      final matchesSearch = name.contains(searchQuery.toLowerCase()) || host.contains(searchQuery.toLowerCase());
      
      final status = room['status'] ?? 'waiting';
      final matchesFilter = activeFilter == 'All' || 
          (activeFilter == 'Waiting' && status == 'waiting') ||
          (activeFilter == 'Playing' && status == 'playing');
          
      return matchesSearch && matchesFilter;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Ionicons.arrow_back, color: Colors.black87),
          onPressed: () => context.go('/'),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Available Rooms', style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
            Text('${filteredRooms.length} rooms found', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search & Filters Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                TextField(
                  onChanged: (val) => setState(() => searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search rooms...',
                    prefixIcon: const Icon(Ionicons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Waiting'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Playing'),
                    ],
                  ),
                )
              ],
            ),
          ),
          
          // Room List
          Expanded(
            child: filteredRooms.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Ionicons.people, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text('No rooms found', style: TextStyle(color: Colors.grey.shade700, fontSize: 16, fontWeight: FontWeight.w500)),
                        Text('Try adjusting your search', style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredRooms.length,
                    itemBuilder: (context, index) {
                      final room = filteredRooms[index];
                      final isWaiting = room['status'] == 'waiting';
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: InkWell(
                          onTap: isWaiting ? () {
                            socketService.joinGame(room['id']);
                            context.go('/play_board');
                          } : null,
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Colors.blue.shade400, Colors.purple.shade600],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Ionicons.trophy, color: Colors.white, size: 24),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'Room ${room['id'].substring(0, 6)}',
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: isWaiting ? Colors.green.shade500 : Colors.grey.shade500,
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  room['status'] ?? 'waiting',
                                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text('Host: ${room['player1Id']}', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Icon(Ionicons.people, size: 14, color: Colors.grey.shade500),
                                              const SizedBox(width: 4),
                                              Text('${room['player2Id'] == null ? 1 : 2}/2', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                              const SizedBox(width: 16),
                                              Icon(Ionicons.trophy, size: 14, color: Colors.grey.shade500),
                                              const SizedBox(width: 4),
                                              Text('${room['maxRounds'] ?? 3} rounds', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                            ],
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                if (isWaiting) ...[
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        socketService.joinGame(room['id']);
                                        context.go('/play_board');
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue.shade600,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        elevation: 0,
                                      ),
                                      child: const Text('Join Room', style: TextStyle(color: Colors.white)),
                                    ),
                                  )
                                ]
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          
          // Bottom Action
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => context.go('/create_game'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Create New Room', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isActive = activeFilter == label;
    return InkWell(
      onTap: () => setState(() => activeFilter = label),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue.shade600 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? Colors.blue.shade600 : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey.shade700,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}