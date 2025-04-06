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
  bool showSecret = false;
  String chatValue = '';

  final TextEditingController _controller = TextEditingController();
  final TextEditingController _chatController = TextEditingController();

  void refreshGuess() async {
    final data = Data().data;
    final userId = Data().userId;

    print('the data in refresh: $data');

    String player = data?['player1'] == userId ? 'player1' : 'player2';
    String opponent = data?['player1'] == userId ? 'player2' : 'player1';
    Data().updateCurrentPlayer(player);
    Data().updateCurrentOpponent(opponent);
    print('the current player is: $player');
    print('the current Opponent is: $opponent');

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
                  onPressed: () => Navigator.of(context).pop(),
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
      BuildContext context) {}

  void checkWinner(Data dataProvider) {
    final winnerData = dataProvider.winner;
    if (winnerData != null) {
      if (winnerData['winnerId'] == null) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Game over!"),
              content: const Text("It's a draw"),
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
      } else if (winnerData['winnerId'] == currentPlayer) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Game over!"),
              content: const Text("Congratulations! You won the game!"),
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
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Game Over!"),
              content: const Text("Sorry! You lost. Better luck next time."),
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

  void sendMessage() {
    final myGameId = Data().gameId;
    final myPlayerId = Data().userId;
    print('my player id: $myPlayerId');
    socketService.chat(
        gameId: myGameId!,
        playerId: myPlayerId!,
        message: _chatController.text);
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

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
    final playBoardProvider = Provider.of<PlayBoardProvider>(context);
    final dataProvider = Provider.of<Data>(context);

    if (dataProvider.lastChance != null) {
      final lastChanceData = Data().lastChance;
      final myData = Data().data;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (lastChanceData?['chanceTo'] == myData?[currentPlayer]) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Last Chance"),
                content: const Text(
                    'Your opponent guessed correctly! This is your last chance to draw the game.'),
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
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Last Chance"),
                content: const Text(
                    'You have guessed correctly! your opponent has a last chance to draw the game.'),
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
      });

      Data().updateLastChance(null);
    }

    // Show dialog only if winner is set (not null)
    if (dataProvider.winner != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final winnerData = Data().winner;
        final myData = Data().data;
        print(
            'this is the winner data $winnerData   the current player is : $currentPlayer');

        if (winnerData?['winnerId'] == null) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Game over!"),
                content: const Text("It's a draw"),
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
        } else if (winnerData?['winnerId'] == myData?[currentPlayer]) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Game over!"),
                content: const Text("Congratulations! You won the game!"),
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
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Game Over!"),
                content: const Text("Sorry! You lost. Better luck next time."),
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

        // Optionally reset the winner so dialog doesn't repeat
        dataProvider.updateWinner(
            null); // Make sure your updateWinner handles null safely
      });
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Text(
              dataProvider.userId == dataProvider.data?['turn']
                  ? 'Your turn'
                  : 'Opponent\'s turn',
              style: const TextStyle(color: Colors.grey, fontSize: 17),
            ),
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
                ? !showSecret
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            showSecret = !showSecret;
                          });
                        },
                        child: const Text(
                          '****',
                          style: TextStyle(fontSize: 20),
                        ),
                      )
                    : GestureDetector(
                        onTap: () {
                          setState(() {
                            showSecret = !showSecret;
                          });
                        },
                        child: Text(
                          mySecret,
                          style: const TextStyle(fontSize: 20),
                        ),
                      )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 35,
                        width: 150,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              mySecret = value;
                            });
                          },
                          decoration: InputDecoration(
                            labelText:
                                mySecret.isEmpty ? 'Enter secret code' : '',
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
                    rows: (dataProvider.data?['guesses']
                                [dataProvider.currentPlayer] as List? ??
                            [])
                        .asMap() // This gives us the index
                        .entries
                        .map<DataRow>((entry) {
                      final index = entry.key;
                      final guess = entry.value as Map<String, dynamic>;

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
                    rows: (dataProvider.data?['guesses']
                                [dataProvider.currentOpponent] as List? ??
                            [])
                        .asMap() // This gives us the index
                        .entries
                        .map<DataRow>((entry) {
                      final index = entry.key;
                      final guess = entry.value as Map<String, dynamic>;

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
                  // color: Colors.grey.shade300,
                  border: Border.all(color: Colors.grey)),
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                      itemCount: dataProvider.chatData?.length,
                      controller: _scrollController,
                      itemBuilder: (context, index) {
                        return Text(
                          dataProvider.chatData?[index]['message'],
                          style: TextStyle(
                              color: dataProvider.chatData?[index]
                                          ['currentSender'] ==
                                      Data().userId
                                  ? Colors.blue
                                  : Colors.grey,
                              fontSize: 18),
                        );
                      })),
            ),
            Row(
              children: [
                SizedBox(
                  height: 35,
                  width: 280,
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        chatValue = value;
                      });
                    },
                    controller: _chatController,
                    decoration: InputDecoration(
                        label: chatValue.isEmpty
                            ? const Text(
                                'text your opponent',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              )
                            : null),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      sendMessage();
                      _chatController.text = '';
                    },
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
                      TextInputType.number, // Enables multi-line input

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
                  checkLastChance(
                      dataProvider, currentPlayer, currentOpponent, context);
                  // checkWinner(dataProvider);

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
