import 'package:flutter/material.dart';
import 'package:png_game/classes/data.dart';
import 'package:png_game/screens/create_room.dart';
import 'package:png_game/screens/play_board.dart';

import 'package:png_game/services/socket_service.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isSigned = false;
  bool isPlayWithFriend = false;
  final socketService = SocketService();

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<Data>(context);
    // print('these are the random games: ${Data().randomGames}');

    if (dataProvider.data?['player2'] != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Navigator.pushNamed(context, '/play_board');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PlayBoard()),
        );
      });
    }
    return Scaffold(
        appBar: AppBar(
          leading: const Icon(
            Icons.menu,
            size: 35,
          ),
          actions: [
            TextButton(
              child: isSigned
                  ? Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 30,
                        color: Colors.grey,
                      ),
                    )
                  : const Text('Sign in'),
              onPressed: () {
                setState(() {
                  isSigned = !isSigned;
                });
              },
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                height: 350,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.grey.shade200),
                width: double.infinity,
                child: ListView.builder(
                    itemCount: dataProvider.randomGames?.length,
                    itemBuilder: (context, index) {
                      String gameId =
                          dataProvider.randomGames?.keys.elementAt(index);
                      var gameData = dataProvider.randomGames?[gameId];

                      return Container(
                        padding: const EdgeInsets.only(bottom: 5, top: 5),
                        decoration: const BoxDecoration(
                          // color: Colors.blue,
                          border: Border(
                            bottom: BorderSide(color: Colors.grey, width: 1),
                          ),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            socketService.joinRandomGames(gameData['gameId']);
                          },
                          child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'anonymous',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Text(
                                  '10',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ]),
                        ),
                      );
                    }),
              ),
              const SizedBox(
                height: 100,
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey.shade300,
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Center(
                  child: TextButton(
                      onPressed: () {
                        socketService.createRandomGame();
                        Navigator.pushNamed(context, '/random_wait_room');
                      },
                      child: const Text(
                        'CREATE A GAME',
                        style: TextStyle(color: Colors.black),
                      )),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey.shade300,
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Center(
                  child: TextButton(
                      onPressed: () {
                        // setState(() {
                        //   isPlayWithFriend = !isPlayWithFriend;
                        // });
                      },
                      child: const Text(
                        'PLAY WITH COMPUTER',
                        style: TextStyle(color: Colors.black),
                      )),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey.shade300,
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Center(
                  child: TextButton(
                      onPressed: () {
                        setState(() {
                          isPlayWithFriend = !isPlayWithFriend;
                        });
                      },
                      child: const Text(
                        'PLAY WITH A FRIEND',
                        style: TextStyle(color: Colors.black),
                      )),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              isPlayWithFriend
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey.shade200,
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: TextButton(
                            onPressed: () {
                              String gameId = socketService.createGame();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CreateRoom(
                                            gameId: gameId,
                                          )));

                              print(gameId);
                            },
                            child: Text(
                              'CREATE GAME',
                              style: TextStyle(color: Colors.grey.shade800),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey.shade200,
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/join_game');
                            },
                            child: Text(
                              'JOIN GAME',
                              style: TextStyle(color: Colors.grey.shade800),
                            ),
                          ),
                        )
                      ],
                    )
                  : const SizedBox()
            ],
          ),
        ));
  }
}
