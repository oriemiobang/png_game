import 'package:flutter/material.dart';
import 'package:png_game/services/playboard_provider.dart';
import 'package:png_game/services/socket_service.dart';
import 'package:provider/provider.dart';

class PlayBoard extends StatefulWidget {
  const PlayBoard({super.key});

  @override
  State<PlayBoard> createState() => _PlayBoardState();
}

class _PlayBoardState extends State<PlayBoard> {
  SocketService socketService = SocketService();

  String mySecret = '';
  String myGuess = '';
  void submitGuess(PlayBoardProvider playBoardProvider) {
    bool isNumb = RegExp(r'^[0-9]+$').hasMatch(myGuess);
    if (myGuess.length == 4 && isNumb) {
      socketService.sendGuess(myGuess);
      playBoardProvider.addGuess(mySecret, '5', '3');
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
    print('enering ');
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
    return Scaffold(
      appBar: AppBar(),
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
            Row(
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
                        print('before entering secret');
                        submitScret(playBoardProvider);
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
                    rows:
                        playBoardProvider.guesses.asMap().entries.map((entry) {
                      final index = entry.key;
                      final guess = entry.value;
                      return DataRow(cells: [
                        DataCell(Text('${index + 1}')),
                        DataCell(Text(guess['guess']!)),
                        DataCell(Text(guess['position']!)),
                        DataCell(Text(guess['number']!)),
                      ]);
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
                    rows:
                        playBoardProvider.guesses.asMap().entries.map((entry) {
                      final index = entry.key;
                      final guess = entry.value;
                      return DataRow(cells: [
                        DataCell(Text('${index + 1}')),
                        DataCell(Text(guess['guess']!)),
                        DataCell(Text(guess['position']!)),
                        DataCell(Text(guess['number']!)),
                      ]);
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
                  onChanged: (value) {
                    setState(() {
                      myGuess = value;
                    });
                  },

                  keyboardType:
                      TextInputType.multiline, // Enables multi-line input

                  maxLines: null, // Expand as needed
                  textInputAction: TextInputAction.newline,
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
                  print('before entering guesses');
                  submitGuess(playBoardProvider);
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
