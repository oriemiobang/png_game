import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PlaySolo extends StatefulWidget {
  const PlaySolo({super.key});

  @override
  State<PlaySolo> createState() => _PlaySoloState();
}

class _PlaySoloState extends State<PlaySolo> {
  final TextEditingController _controller = TextEditingController();

  Map<String, dynamic> guesses = {'gameId': '', 'secret': '', 'guesses': []};
  bool isGameOver = false;

  String generateUniqueFourDigitNumber() {
    final random = Random();
    List<int> digits = List.generate(10, (i) => i); // [0-9]
    digits.shuffle(random);

    // Take the first 4 unique digits
    List<int> selectedDigits = digits.take(4).toList();

    return selectedDigits.join(); // Convert to string
  }

  void starter() {
    final random = Random();
    List<int> digits = List.generate(10, (i) => i); // [0-9]
    digits.shuffle(random);
    const hexChars = '0123456789abcdef';

    // Take the first 4 unique digits
    List<int> selectedDigits = digits.take(4).toList();

    String secret = selectedDigits.join(); // Convert to string
    String gameId =
        'PNG${List.generate(15, (_) => hexChars[random.nextInt(16)]).join()}';

    guesses['gameId'] = gameId;
    guesses['secret'] = secret;
    // 'gameId': '',
    // 'secret': '',
  }

  @override
  void initState() {
    starter();
    // TODO: implement initState
    super.initState();
  }

  void playCheck(String guess) {
    bool isNumb = RegExp(r'^\d+$').hasMatch(guess);
    bool isUnique = guess.split('').toSet().length == guess.length;

    if (isUnique && isNumb && guess.length == 4) {
      String mySecret = guesses['secret'];
      int position = 0;
      int number = 0;
      for (int i = 0; i < guess.length; i++) {
        if (guess[i] == mySecret[i]) {
          position++;
        }
        if (mySecret.contains(guess[i])) {
          number++;
        }
      }
      guesses['guesses'].add({
        'guess': guess,
        'number': '$number',
        'position': '$position',
      });

      setState(() {});

      if (position == 4) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("You won!"),
              content: Text(
                  'Congratulations! You have correctly guessed the number after ${guesses['guesses'].length} attempts.'),
              actions: [
                TextButton(
                  onPressed: () {
                    isGameOver = true;
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    guesses = {'gameId': '', 'secret': '', 'guesses': []};
                    starter();
                    isGameOver = false;
                    setState(() {});
                    Navigator.pop(context);
                  },
                  child: const Text("New Game"),
                ),
              ],
            );
          },
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Invalid input!"),
            content: const Text(
                'Please enter only 4 digits number with no repetitions!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('Ok'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            if (!isGameOver) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Guit game?"),
                    content:
                        const Text('Are you sure you want to guit the game?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('No'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.pop();
                          // Navigator.pushReplacementNamed(
                          //     context, '/'); // Close the dialog
                        },
                        child: const Text('Yes'),
                      ),
                    ],
                  );
                },
              );
            } else {
              Navigator.pop(context);
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            // Container(
            //   width: 170,
            //   height: 40,
            //   color: Colors.grey.shade200,
            //   child: Padding(
            //     padding: const EdgeInsets.all(8.0),
            //     child: Center(
            //       child: Text(
            //         'My board',
            //         style: TextStyle(color: Colors.grey.shade800),
            //       ),
            //     ),
            //   ),
            // ),
            const SizedBox(
              height: 10,
            ),
            DataTable(
              columnSpacing: 20,
              headingRowColor: WidgetStateProperty.all(Colors.grey.shade300),
              columns: const [
                DataColumn(
                  label: Text(
                    'Attempt',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Guesses',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'P',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'N',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: (guesses['guesses'] as List<dynamic>)
                  .asMap()
                  .entries
                  .map<DataRow>((entry) {
                final index = entry.key + 1; // attempt number (1-based)
                final guess = entry.value as Map<String, dynamic>;

                return DataRow(
                  cells: [
                    DataCell(Text(index.toString())), // Attempt number
                    DataCell(Text(guess['guess'] ?? '')),

                    DataCell(Text(guess['position'] ?? '')),
                    DataCell(Text(guess['number'] ?? '')),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(
              height: 20,
            ),
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
                onTap: isGameOver
                    ? null
                    : () {
                        String secret = _controller.text;
                        _controller.text = '';
                        playCheck(secret);
                      },
                child: Container(
                  decoration: BoxDecoration(
                      color: isGameOver ? Colors.grey.shade300 : Colors.green),
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
