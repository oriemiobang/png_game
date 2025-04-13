import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:png_game/classes/data.dart';
// import 'package:png_game/main.dart';
import 'package:png_game/screens/create_room.dart';
// import 'package:png_game/screens/play_board.dart';

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
  // final socketService = SocketService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  SocketService socketService = SocketService();

  @override
  void initState() {
    listener();
    // TODO: implement initState
    super.initState();
  }

  void listener() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dataProvider = Provider.of<Data>(context, listen: false);

      dataProvider.addListener(() {
        if (socketService.gameJoined) {
          // Navigator.pushNamed(context, '/play_board');
          context.go('/play_board');
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => const PlayBoard()),
          // );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<Data>(context);
    // // print('these are the random games: ${Data().randomGames}');

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (dataProvider.data?['player2'] != null) {
    //     // Navigator.pushNamed(context, '/play_board');
    //     Navigator.push(
    //       context,
    //       MaterialPageRoute(builder: (context) => PlayBoard()),
    //     );
    //   }
    // });
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          actions: [],
        ),
        drawer: Container(
          decoration: BoxDecoration(
            color: Colors.white, // Background color
            borderRadius: BorderRadius.circular(0), // Circularity of 10
          ),
          width: 250,
          child: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                SizedBox(
                  height: 150,
                  child: InkWell(
                    onTap: () {
                      // Navigator.pushNamed(context, '/signin');
                      context.push('/signin');
                    },
                    splashColor:
                        Colors.grey.withOpacity(0.3), // Adjust splash color
                    highlightColor: Colors.grey.withOpacity(0.3),
                    child: DrawerHeader(
                      decoration: BoxDecoration(),
                      child: Row(
                        children: [
                          Icon(
                            Icons
                                .account_circle_rounded, // Change to your desired icon
                            size: 60, // Size of the icon
                            color: Colors.black54, // Color of the icon
                          ),
                          SizedBox(width: 10),
                          Text('login or register',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 25.0),
                  leading: Icon(Icons.home),
                  title: Text('Home'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 25.0),
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                  onTap: () {
                    // Close the drawer
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 25.0),
                  leading: Icon(Icons.question_mark_outlined),
                  title: Text('About us'),
                  onTap: () {
                    // Handle the tap
                    Navigator.pop(context); // Close the drawer
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 25.0),
                  leading: Icon(Icons.thumb_up_sharp),
                  title: Text('Rate us'),
                  onTap: () {
                    // Handle the tap
                    Navigator.pop(context); // Close the drawer
                  },
                ),
              ],
            ),
          ),
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
                        // Navigator.pushNamed(context, '/random_wait_room');
                        context.push('/random_wait_room');
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
                        // Navigator.pushNamed(context, '/play_solo');
                        context.push('/play_solo');
                        // setState(() {
                        //   isPlayWithFriend = !isPlayWithFriend;
                        // });
                      },
                      child: const Text(
                        'PLAY SOLO',
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
                              // Navigator.pushNamed(context, '/join_game');
                              context.push('/join_game');
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
