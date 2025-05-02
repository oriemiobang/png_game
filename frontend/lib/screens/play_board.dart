import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:png_game/classes/data.dart';
import 'package:png_game/classes/play_board_classes.dart';
import 'package:png_game/firebase_service/auth.dart';
import 'package:png_game/firebase_service/database_service.dart';
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
  Data myData = Data();

  final TextEditingController _controller = TextEditingController();
  final TextEditingController _chatController = TextEditingController();
  AuthService _authService = AuthService();
  DatabaseService _databaseService = DatabaseService();

  void refreshGuess() async {
    // final dataProvider = Provider.of<Data>(context, listen: false);
    final data = Data().data;
    // final data = dataProvider.data;
    // final userId = dataProvider.userId;

    final userId = Data().userId;
    // print('this is the data: $data');
    String player = data?['player1'] == userId ? 'player1' : 'player2';
    String opponent = data?['player1'] == userId ? 'player2' : 'player1';
    Data().updateCurrentPlayer(player);
    Data().updateCurrentOpponent(opponent);
    setState(() {
      currentOpponent = opponent;
      currentPlayer = player;
    });
  }

  @override
  void initState() {
    refreshGuess();
    listener();

    // TODO: implement initState
    super.initState();
  }

  String myGuess = '';
  String currentPlayer = '';
  String currentOpponent = '';

  void submitGuess(PlayBoardProvider playBoardProvider) {
    // bool isNumb = RegExp(r'^[0-9]+$').hasMatch(myGuess);
    bool isNumb = RegExp(r'^\d+$').hasMatch(myGuess);
    bool isUnique = myGuess.split('').toSet().length == myGuess.length;

    if (myGuess.length == 4 && isNumb && isUnique) {
      socketService.sendGuess(myGuess);

      // playBoardProvider.addGuess(mySecret, '5', '3');
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Invalid Input"),
            content:
                const Text("Please enter a 4-digit number with no repetition!"),
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
    socketService.chat(
        gameId: myGameId!,
        playerId: myPlayerId!,
        message: _chatController.text);
  }

  void submitScret(PlayBoardClasses playBoardClasees) {
    final mySecret = playBoardClasees.mySecret;
    bool isNumb = RegExp(r'^[0-9]+$').hasMatch(mySecret);

    if (mySecret.length == 4 && isNumb) {
      socketService.submitSecret(mySecret);
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
  final ScrollController _tableScrollCtroller = ScrollController();

  // change listener
  void listener() {
    final dataProvider = Provider.of<Data>(context, listen: false);

    //end
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_tableScrollCtroller.hasClients) {
        _tableScrollCtroller.animateTo(
          _tableScrollCtroller.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    });
    final playBoardProvider = Provider.of<PlayBoardProvider>(context);
    final dataProvider = Provider.of<Data>(context);
    final playBoardClasses = Provider.of<PlayBoardClasses>(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
// check for new game request
      if (dataProvider.newGame != null) {
        final requestData = dataProvider.newGame;
        final myId = dataProvider.userId;
        print('here is the request data: $requestData');
        if (requestData?['isApproved'] == false) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("New game"),
                content: const Text('Let\'s play a new game'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('No'),
                  ),
                  TextButton(
                    onPressed: () {
                      final playerId = dataProvider.userId;
                      final gameId = dataProvider.gameId;
                      socketService.requestNewGame(playerId, gameId, true);
                      Navigator.of(context).pop();
                    },
                    child: const Text("OK"),
                  ),
                ],
              );
            },
          );
        } else if (requestData?['isApproved'] == true) {
          PlayBoardClasses().setGuesses([]);
          PlayBoardClasses().setIsSubmitted(false);
          PlayBoardClasses().setMySecret('');
          PlayBoardClasses().setShowSecret(false);
          Data().updateGameOver(false);
          dataProvider.updateChatData({});

          Fluttertoast.showToast(
              msg: "New game started!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: const Color.fromARGB(255, 0, 4, 17),
              textColor: Colors.white,
              fontSize: 16.0);
        }
        Data().updateNewGame(null);
      }
    });
    // check for your turn
    if (dataProvider.notYourTurn != null) {
      if (dataProvider.notYourTurn?['player'] == dataProvider.userId) {
        Fluttertoast.showToast(
            msg: "Please wait for your turn!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: const Color.fromARGB(255, 0, 4, 17),
            textColor: Colors.white,
            fontSize: 16.0);

        Data().updateNotYourTurn(null);
      }
    }

// check for last chancce
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
                      Navigator.of(context).pop(); 
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
                      Navigator.of(context).pop(); 
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

    // check for a winner
    // Show dialog only if winner is set (not null)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (dataProvider.winner != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final winnerData = Data().winner;
          final myData = Data().data;
          if (winnerData?['winnerId'] == null) {
            Data().updateGameOver(true);
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Game over!"),
                  content: const Text("It's a draw"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); 
                      },
                      child: const Text("OK"),
                    ),
                  ],
                );
              },
            );
          } else if (winnerData?['winnerId'] == myData?[currentPlayer]) {
            Data().updateGameOver(true);
            showDialog(
              context: context,
              builder: (BuildContext context) {
                
                return AlertDialog(
                  title: const Text("Game over!"),
                  content: const Text("Congratulations! You won the game!"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); 
                      },
                      child: const Text("OK"),
                    ),
                  ],
                );
              },
            );
          } else {
            Data().updateGameOver(true);
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Game Over!"),
                  content:
                      const Text("Sorry! You lost. Better luck next time."),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("OK"),
                    ),
                  ],
                );
              },
            );
          }

      
          dataProvider.updateWinner(
              null); 
        });
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult:(didPop, result) {
        if(!didPop){
        
                if (dataProvider.gameOver) {
                  PlayBoardClasses().setChatValue('');
                  PlayBoardClasses().setGuesses([]);
                  PlayBoardClasses().setIsSubmitted(false);
                  PlayBoardClasses().setMySecret('');
                  PlayBoardClasses().setShowSecret(false);
                  Data().updateGameOver(false);
                  Data().updateChatData({});
                
                  // Navigator.pushNamed(context, '/');
                  context.go('/');
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Leave game?"),
                        content: const Text(
                            "Are you sure you want to leave the game?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('No'),
                          ),
                          TextButton(
                            onPressed: () {
                              PlayBoardClasses().setChatValue('');
                              PlayBoardClasses().setGuesses([]);
                              PlayBoardClasses().setIsSubmitted(false);
                              PlayBoardClasses().setMySecret('');
                              PlayBoardClasses().setShowSecret(false);
                              Data().updateGameOver(false);
                                Data().updateChatData({});
                           
                              // Navigator.pushNamed(context, '/');
                              Navigator.of(context).pop(); // Close the dialog
                              context.go('/');
                            },
                            child: const Text("Yes"),
                          ),
                        ],
                      );
                    },
                  );
                }
              

        }
        
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
              onPressed: () {
                if (dataProvider.gameOver) {
                  PlayBoardClasses().setChatValue('');
                  PlayBoardClasses().setGuesses([]);
                  PlayBoardClasses().setIsSubmitted(false);
                  PlayBoardClasses().setMySecret('');
                  PlayBoardClasses().setShowSecret(false);
                  Data().updateGameOver(false);
                  Data().updateChatData({});
                
                  // Navigator.pushNamed(context, '/');
                  context.go('/');
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Leave game?"),
                        content: const Text(
                            "Are you sure you want to leave the game?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('No'),
                          ),
                          TextButton(
                            onPressed: () {
                              PlayBoardClasses().setChatValue('');
                              PlayBoardClasses().setGuesses([]);
                              PlayBoardClasses().setIsSubmitted(false);
                              PlayBoardClasses().setMySecret('');
                              PlayBoardClasses().setShowSecret(false);
                              Data().updateGameOver(false);
                                Data().updateChatData({});
                           
                              // Navigator.pushNamed(context, '/');
                              Navigator.of(context).pop(); // Close the dialog
                              context.go('/');
                            },
                            child: const Text("Yes"),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              icon: const Icon(Icons.arrow_back)),
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
              playBoardClasses.isSubmitted
                  ? !playBoardClasses.showSecret
                      ? GestureDetector(
                          onTap: () => playBoardClasses
                              .setShowSecret(!playBoardClasses.showSecret),
                          child: const Text(
                            '****',
                            style: TextStyle(fontSize: 20),
                          ),
                        )
                      : GestureDetector(
                          onTap: () => playBoardClasses
                              .setShowSecret(!playBoardClasses.showSecret),
                          child: Text(
                            playBoardClasses.mySecret,
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
                              PlayBoardClasses().setMySecret(value);
                            },
                            decoration: InputDecoration(
                              labelText: playBoardClasses.mySecret.isEmpty
                                  ? 'Enter secret code'
                                  : '',
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
                                if (dataProvider.data?['turn'] ==
                                    dataProvider.userId) {
                                  submitScret(playBoardClasses);
                                  PlayBoardClasses().setIsSubmitted(true);
                                } else {
                                  Fluttertoast.showToast(
                                      msg: "Please wait for your turn!",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor:
                                          const Color.fromARGB(255, 0, 4, 17),
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                }
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
                  ? Container(
                      height: 300,
                      width: double.infinity,
                      color: Colors.grey.shade200,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header row (fixed)
                          Container(
                            color: Colors.grey.shade300,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            child: const Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    'Attempt',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Guesses',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    'P',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    'N',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          dataProvider
                                      .data?['guesses']
                                          [dataProvider.currentPlayer]
                                      .length <
                                  1
                              ? const Center(
                                  child: Text(
                                    'your guesses appears here',
                                    style: TextStyle(fontStyle: FontStyle.italic),
                                  ),
                                )
                              :
                              // Scrollable rows
                              Expanded(
                                  child: Scrollbar(
                                    thumbVisibility: true,
                                    controller: _tableScrollCtroller,
                                    child: SingleChildScrollView(
                                      controller: _tableScrollCtroller,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: SizedBox(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Column(
                                            children: (dataProvider
                                                                .data?['guesses']
                                                            ?[
                                                            dataProvider
                                                                .currentPlayer]
                                                        as List?)
                                                    ?.map<Widget>((entry) {
                                                  final index = (dataProvider
                                                                      .data?[
                                                                  'guesses'][
                                                              dataProvider
                                                                  .currentPlayer]
                                                          as List)
                                                      .indexOf(entry);
                                                  final guess = entry
                                                      as Map<String, dynamic>;
      
                                                  return Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 16,
                                                        vertical: 8),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                            flex: 1,
                                                            child: Text(
                                                                '${index + 1}')),
                                                        Expanded(
                                                          flex: 2,
                                                          child: Text(guess[
                                                                      'guess']
                                                                  ?.toString() ??
                                                              ''),
                                                        ),
                                                        Expanded(
                                                          flex: 1,
                                                          child: Text(guess[
                                                                          'feedback']
                                                                      ?[
                                                                      'position']
                                                                  ?.toString() ??
                                                              ''),
                                                        ),
                                                        Expanded(
                                                          flex: 1,
                                                          child: Text(guess[
                                                                          'feedback']
                                                                      ?['number']
                                                                  ?.toString() ??
                                                              ''),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }).toList() ??
                                                [], // Return empty list if null
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    )
                  : Container(
                      height: 300,
                      width: double.infinity,
                      color: Colors.grey.shade200,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header row (fixed)
                          Container(
                            color: Colors.grey.shade300,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            child: const Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    'Attempt',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Guesses',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    'P',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    'N',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          dataProvider
                                      .data?['guesses']
                                          [dataProvider.currentOpponent]
                                      .length <
                                  1
                              ? const Center(
                                  child: Text(
                                    'your guesses appears here',
                                    style: TextStyle(fontStyle: FontStyle.italic),
                                  ),
                                )
                              :
                              // Scrollable rows
                              Expanded(
                                  child: Scrollbar(
                                    thumbVisibility: true,
                                    controller: _tableScrollCtroller,
                                    child: SingleChildScrollView(
                                      controller: _tableScrollCtroller,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: SizedBox(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Column(
                                            children: (dataProvider
                                                                .data?['guesses']
                                                            ?[
                                                            dataProvider
                                                                .currentOpponent]
                                                        as List?)
                                                    ?.map<Widget>((entry) {
                                                  final index = (dataProvider
                                                                      .data?[
                                                                  'guesses'][
                                                              dataProvider
                                                                  .currentOpponent]
                                                          as List)
                                                      .indexOf(entry);
                                                  final guess = entry
                                                      as Map<String, dynamic>;
      
                                                  return Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 16,
                                                        vertical: 8),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                            flex: 1,
                                                            child: Text(
                                                                '${index + 1}')),
                                                        Expanded(
                                                          flex: 2,
                                                          child: Text(guess[
                                                                      'guess']
                                                                  ?.toString() ??
                                                              ''),
                                                        ),
                                                        Expanded(
                                                          flex: 1,
                                                          child: Text(guess[
                                                                          'feedback']
                                                                      ?[
                                                                      'position']
                                                                  ?.toString() ??
                                                              ''),
                                                        ),
                                                        Expanded(
                                                          flex: 1,
                                                          child: Text(guess[
                                                                          'feedback']
                                                                      ?['number']
                                                                  ?.toString() ??
                                                              ''),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }).toList() ??
                                                [], // Return empty list if null
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      ),
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
                        }),),
              ),
              Row(
                children: [
                  SizedBox(
                    height: 35,
                    width: 280,
                    child: TextField(
                      onChanged: (value) {
                        PlayBoardClasses().setChatValue(value);
                      },
                      controller: _chatController,
                      decoration: InputDecoration(
                          label: playBoardClasses.chatValue.isEmpty
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
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                  width: 170,
                  color:
                      dataProvider.gameOver ? Colors.black : Colors.grey.shade300,
                  child: TextButton(
                      onPressed: () {
                        final gameId = Data().gameId;
                        final playerId = Data().userId;
                        socketService.requestNewGame(playerId, gameId, false);
                      },
                      child: const Text(
                        'New game',
                        style: TextStyle(fontSize: 17, color: Colors.white),
                      )))
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
                    // checkLastChance(
                    //     dataProvider, currentPlayer, currentOpponent, context);
                    // // checkWinner(dataProvider);
      
                    _controller.text = '';
                  },
                  child: Container(
                    decoration: const BoxDecoration(color: Colors.black),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Submit', style: TextStyle(color: Colors.white),),
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
}
