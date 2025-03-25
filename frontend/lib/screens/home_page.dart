import 'package:flutter/material.dart';
import 'package:png_game/screens/create_room.dart';
import 'package:png_game/services/socket_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isSigned = false;
  bool isPlayWithFriend = false;
  final socketService = SocketService();
  List<Map<String, String>> playerList = [
    {
      'name': 'Player 1',
      'time': '10',
    },
    {
      'name': 'Samuel',
      'time': '10',
    },
    {
      'name': 'Yishak',
      'time': '10',
    },
    {
      'name': 'peter',
      'time': '10',
    },
    {
      'name': 'anonymous',
      'time': '10',
    },
    {
      'name': 'anonymous',
      'time': '10',
    },
    {
      'name': 'john',
      'time': '10',
    }
  ];
  @override
  Widget build(BuildContext context) {
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
              SizedBox(
                height: 450,
                width: double.infinity,
                child: ListView.builder(
                    itemCount: playerList.length,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.only(bottom: 5, top: 5),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey, width: 1),
                          ),
                        ),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                playerList[index]['name']!,
                                style: const TextStyle(fontSize: 16),
                              ),
                              Text(
                                playerList[index]['time']!,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ]),
                      );
                    }),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey.shade300,
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Center(
                  child: TextButton(
                      onPressed: () {},
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
