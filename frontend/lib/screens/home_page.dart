import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ionicons/ionicons.dart';
import 'package:png_game/classes/data.dart';
import 'package:png_game/firebase_service/auth.dart';
import 'package:png_game/models/my_user.dart';
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
    final AuthService _auth = AuthService();

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
     final user = Provider.of<MyUser?>(context);
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
      backgroundColor: Colors.grey.shade50,
      // backgroundColor: Colors.black87,
        key: _scaffoldKey,

appBar: AppBar(
  forceMaterialTransparency: true,
  // give the leading area more room so icon + text are more visible
  leadingWidth: 160,
  leading: Padding(
    padding: const EdgeInsets.only(left: 12.0),
    child: Row(
      children: const [
        Icon(Icons.gamepad_outlined, size: 30, color: Colors.blue,),
        SizedBox(width: 8),
        Text(
          'PNG',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
      ],
    ),
  ),
  actions: [
    IconButton(
      icon: const Icon(Icons.menu),
      onPressed: () {
        _scaffoldKey.currentState?.openDrawer();
      },
    ),
  ],
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
                  child: user != null? Center(child: ListTile(leading: Icon(Icons.person, size: 40,), 
                  title: Text('Oriemi Obang', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ),) : InkWell(
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

                user != null? ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 25.0),
                  leading: Icon(Icons.logout),
                  title: Text('Log out'),
                  onTap: () {
                    _auth.signOut();
                   // handle log out
                   
                  },

                ): SizedBox()
              ],
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: ListView(
          
            children: [
              Divider(),
              SizedBox(height: 18,),
              Text('Game Rooms', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
              Container(
                padding: const EdgeInsets.all(10),
                height: 350,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white),
                width: double.infinity,
                child: ListView.builder(
                    itemCount: dataProvider.randomGames?.length,
                    itemBuilder: (context, index) {
                      String gameId =
                          dataProvider.randomGames?.keys.elementAt(index);
                      var gameData = dataProvider.randomGames?[gameId];

                      return Container(
                        
                        padding: const EdgeInsets.all(5),
                        decoration:  BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          // color: Colors.blue,
                          border: Border.all(
                            color: Color.fromARGB(255, 221, 221, 221),
                          ),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            socketService.joinRandomGames(gameData['gameId']);
                          },
                          child: ListTile(
                            leading: CircleAvatar(child: Icon(Icons.person)),
                            title: Text("Anonymous", style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18
                            ),),
                            subtitle: Text('20 min'),
                          )
                        ),
                      );
                    }),
              ),
              const SizedBox(
                height: 10,
              ),
              Text('Play Options', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
               const SizedBox(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.blue,
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_arrow_outlined, size: 30, color: Colors.white,),
                          const Text(
                            'Play Solo',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      )),
                ),
              ),
                SizedBox(height: 12,),

              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.blue,
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Center(
                  child: TextButton(
                      onPressed: () {
                        socketService.createRandomGame();
                        // Navigator.pushNamed(context, '/random_wait_room');
                        context.push('/random_wait_room');
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, size: 30, color: Colors.white,),
                          const Text(
                            'Create Room',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      )),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
          
              Text('Play with a Friend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
               const SizedBox(
                height: 12,
              ),

             Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                 GestureDetector(
                  onTap: () {
                            String gameId = socketService.createGame();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CreateRoom(
                                            gameId: gameId,
                                          )));

                              print(gameId);
                  },
                   child: Container(
                    padding: const EdgeInsets.all(20),
                                   decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    
                    // color:  Colors.blue,
                    border: Border.all(color: Colors.grey.shade300),
                                   ) ,
                                   child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.qr_code, size: 50, color: Colors.green,),
                        Text('Share Room', style: TextStyle(fontWeight: FontWeight.bold),),
                        SizedBox(height: 5,),
                        Text('Generate a Qr for \n friends')
                      ],
                    ),
                                   ),
                                 ),
                 ),


                     GestureDetector(
                      onTap: () =>  context.push('/join_game'),
                       child: Container(
                                         padding: const EdgeInsets.all(20),
                                       decoration: BoxDecoration(
                                         borderRadius: BorderRadius.circular(10),
                                         
                                         // color:  Colors.blue,
                                         border: Border.all(color: Colors.grey.shade300),
                                       ) ,
                                       child: Center(
                                         child: Column(
                                           children: [
                        Icon(Ionicons.scan_outline, size: 50, color: Colors.green,),
                        Text('Scan QR, Enter Code', style: TextStyle(fontWeight: FontWeight.bold),),
                        SizedBox(height: 5,),
                        Text('Join Via Qr or enter \n code')
                                           ],
                                         ),
                                       ),
                                     ),
                     )
              ],
             )




              ,
              // Container(
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(10),
              //     color:  const Color.fromARGB(71, 64, 131, 255),
              //     border: Border.all(color: Colors.grey.shade200),
              //   ),
              //   child: Center(
              //     child: TextButton(
              //         onPressed: () {
              //           setState(() {
              //             isPlayWithFriend = !isPlayWithFriend;
              //           });
              //         },
              //         child: const Text(
              //           'PLAY WITH A FRIEND',
              //           style: TextStyle(color: Colors.black),
              //         )),
              //   ),
              // ),
              // const SizedBox(
              //   height: 15,
              // ),
              // isPlayWithFriend
              //     ? Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceAround,
              //         children: [
              //           Container(
              //             decoration: BoxDecoration(
              //               borderRadius: BorderRadius.circular(10),
              //               color:  const Color.fromARGB(71, 64, 131, 255),
              //               border: Border.all(color: Colors.grey.shade100),
              //             ),
              //             child: TextButton(
              //               onPressed: () {
              //                 String gameId = socketService.createGame();
              //                 Navigator.push(
              //                     context,
              //                     MaterialPageRoute(
              //                         builder: (context) => CreateRoom(
              //                               gameId: gameId,
              //                             )));

              //                 print(gameId);
              //               },
              //               child: Text(
              //                 'CREATE GAME',
              //                 style: TextStyle(color: Colors.grey.shade800),
              //               ),
              //             ),
              //           ),
              //           Container(
              //             decoration: BoxDecoration(
              //               borderRadius: BorderRadius.circular(10),
              //               color:  const Color.fromARGB(71, 64, 131, 255),
              //               border: Border.all(color: Colors.grey.shade100),
              //             ),
              //             child: TextButton(
              //               onPressed: () {
              //                 // Navigator.pushNamed(context, '/join_game');
              //                 context.push('/join_game');
              //               },
              //               child: Text(
              //                 'JOIN GAME',
              //                 style: TextStyle(color: Colors.grey.shade800),
              //               ),
              //             ),
              //           )
              //         ],
              //       )
              //     : const SizedBox()
            ],
          ),
        ));
  }
}
