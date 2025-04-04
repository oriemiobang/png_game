import 'package:flutter/material.dart';
import 'package:png_game/classes/data.dart';
import 'package:png_game/services/playboard_provider.dart';
import 'package:png_game/services/socket_service.dart';
import 'package:png_game/storage/saved_data.dart';
import 'package:provider/provider.dart';

class PlayBoard extends StatefulWidget {
  const PlayBoard({super.key});

  @override
  State<PlayBoard> createState() => _PlayBoardState();
}

class _PlayBoardState extends State<PlayBoard> {
  SocketService socketService = SocketService();
  SavedData savedData = SavedData();
  List guesses = [];
  String mySecret = '';
  Data myData = Data();
  bool isSubmitted = false;

  final TextEditingController _controller = TextEditingController();

  void refreshGuess() async {
    final data = Data().data;
    final userId = Data().userId;

    String player = data?['player1'] == userId ? 'player1' : 'player2';
    String opponent = data?['player1'] == userId ? 'player2' : 'player1';

    // Add this check
    setState(() {
      // guesses = data?['guesses'][player];
      currentOpponent = opponent;
      currentPlayer = player;
    });
  }

  @override
  void initState() {
    refreshGuess();
    // TODO: implement initState
    super.initState();
  }

  String myGuess = '';
  String currentPlayer = '';
  String currentOpponent = '';

  void _showCustomDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Ok',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void checkLastChance(Data dataProvider, String currentPlayer, String opponent,
      BuildContext context) {
    final data = dataProvider.data;

    // Early null safety checks
    if (data == null || data['lastChance'] != true || data['guesses'] == null)
      return;

    final guesses = data['guesses'];
    final currentPlayerGuesses = guesses[currentPlayer] ?? [];
    final opponentGuesses = guesses[opponent] ?? [];

    // Determine message and show dialog safely after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (currentPlayerGuesses.length < opponentGuesses.length) {
        _showCustomDialog(
          context,
          'Last chance',
          'Your opponent has guessed correctly.\nYou have one last chance to draw the game.',
        );
      } else {
        _showCustomDialog(
          context,
          'Last chance',
          'You have guessed the number correctly.\nYour opponent has one last chance to draw the game.',
        );
      }
    });
  }

  void submitGuess(PlayBoardProvider playBoardProvider) {
    bool isNumb = RegExp(r'^[0-9]+$').hasMatch(myGuess);
    if (myGuess.length == 4 && isNumb) {
      socketService.sendGuess(myGuess);

      // playBoardProvider.addGuess(mySecret, '5', '3');
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Invalid Input"),
            content: const Text("Please enter a 4-digit number."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  void submitScret(PlayBoardProvider playBoardProvider) {
    bool isNumb = RegExp(r'^[0-9]+$').hasMatch(mySecret);

    if (mySecret.length == 4 && isNumb) {
      socketService.submitSecret(mySecret);
      playBoardProvider.submitSecret();
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Invalid Input"),
            content: const Text("Please enter a 4-digit number."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final playBoardProvider = Provider.of<PlayBoardProvider>(context);
    final dataProvider = Provider.of<Data>(context);
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: EdgeInsets.only(left: 10, right: 0),
            child: Text(dataProvider.userId == dataProvider.data?['turn']
                ? 'Your turn'
                : 'Opponent\'s turn'),
          ),
          Padding(
            padding: EdgeInsets.only(left: 0, right: 50),
            child: Text(currentPlayer),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            // playBoardProvider.secretSubmitted
            //     ? GestureDetector(
            //         onTap: playBoardProvider.toggleHideText,
            //         child: Align(
            //           alignment:
            //               Alignment.centerLeft, // Adjust alignment if needed
            //           child: Container(
            //             width: 60,
            //             height: 50,
            //             decoration: BoxDecoration(
            //               borderRadius: BorderRadius.circular(5),
            //               color: Colors.grey.shade100,
            //             ),
            //             child: Center(
            //               child: playBoardProvider.hideText
            //                   ? const Text('****')
            //                   : Text(mySecret),
            //             ), // Center text inside
            //           ),
            //         ),
            //       )
            // :
            isSubmitted
                ? Text(mySecret)
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 35,
                        width: 150,
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              mySecret = value;
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Enter secret code',
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Container(
                        color: Colors.green,
                        height: 35,
                        child: TextButton(
                            onPressed: () {
                              submitScret(playBoardProvider);
                              setState(() {
                                isSubmitted = true;
                              });
                            },
                            child: const Text(
                              'Submit',
                              style: TextStyle(color: Colors.black),
                            )),
                      )
                    ],
                  ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => playBoardProvider.toggleBoard(true),
                  child: Container(
                    width: 170,
                    color: playBoardProvider.showMine
                        ? Colors.grey.shade200
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'My board',
                        style: TextStyle(color: Colors.grey.shade800),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => playBoardProvider.toggleBoard(false),
                  child: Container(
                    width: 170,
                    color: !playBoardProvider.showMine
                        ? Colors.grey.shade200
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Opponent\'s board',
                        style: TextStyle(color: Colors.grey.shade800),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            playBoardProvider.showMine
                ? DataTable(
                    columnSpacing: 20,
                    headingRowColor:
                        WidgetStateProperty.all(Colors.grey.shade300),
                    columns: const [
                      DataColumn(
                          label: Text('Attempt',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Guesses',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('P',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('N',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: (dataProvider.data?['guesses'][currentPlayer]
                                as List? ??
                            [])
                        .asMap() // This gives us the index
                        .entries
                        .map<DataRow>((entry) {
                      final index = entry.key;
                      final guess = entry.value as Map<String, dynamic>;
                      checkLastChance(dataProvider, currentPlayer,
                          currentOpponent, context);

                      return DataRow(
                        cells: [
                          DataCell(Text(
                              '${index + 1}')), // Here's your attempt number
                          DataCell(Text(guess['guess']?.toString() ?? '')),
                          DataCell(Text(
                              guess['feedback']?['position']?.toString() ??
                                  '')),
                          DataCell(Text(
                              guess['feedback']?['number']?.toString() ?? '')),
                        ],
                      );
                    }).toList(),
                  )
                : DataTable(
                    columnSpacing: 20,
                    headingRowColor:
                        WidgetStateProperty.all(Colors.grey.shade300),
                    columns: const [
                      DataColumn(
                          label: Text('Attempt',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Guesses',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('P',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('N',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: (dataProvider.data?['guesses'][currentOpponent]
                                as List? ??
                            [])
                        .asMap() // This gives us the index
                        .entries
                        .map<DataRow>((entry) {
                      final index = entry.key;
                      final guess = entry.value as Map<String, dynamic>;
                      checkLastChance(dataProvider, currentPlayer,
                          currentOpponent, context);

                      return DataRow(
                        cells: [
                          DataCell(
                            Text('${index + 1}'),
                          ), // Here's your attempt number
                          DataCell(Text(guess['guess']?.toString() ?? '')),
                          DataCell(Text(
                              guess['feedback']?['position']?.toString() ??
                                  '')),
                          DataCell(Text(
                              guess['feedback']?['number']?.toString() ?? '')),
                        ],
                      );
                    }).toList(),
                  ),
            const SizedBox(
              height: 20,
            ),
            Container(
              height: 150,
              // width: 350,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.grey.shade300,
              ),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Sign in to chat',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ),
            Row(
              children: [
                const SizedBox(
                  height: 35,
                  width: 280,
                  child: TextField(
                    decoration: InputDecoration(
                        label: Text(
                      'text your opponent',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    )),
                  ),
                ),
                IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.send,
                      color: Colors.grey.shade500,
                      size: 35,
                    ))
              ],
            )
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SizedBox(
          width: double.infinity,
          // height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                padding: const EdgeInsetsDirectional.only(start: 20),
                width: 250,
                // height: 45,
                child: TextField(
                  keyboardType:
                      TextInputType.multiline, // Enables multi-line input

                  maxLines: null, // Expand as needed
                  textInputAction: TextInputAction.newline,
                  controller: _controller,
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    hintText: 'Write your guess...',
                    // border: OutlineInputBorder(
                    //   borderRadius: BorderRadius.circular(25),
                    //   borderSide: BorderSide(color: Colors.grey.shade200),
                    // ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    myGuess = _controller.text;
                  });
                  submitGuess(playBoardProvider);
                  _controller.text = '';
                },
                child: Container(
                  decoration: const BoxDecoration(color: Colors.green),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Submit'),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
