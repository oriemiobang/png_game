import 'dart:math';

import 'package:flutter/material.dart';

class PlaySolo extends StatefulWidget {
  const PlaySolo({super.key});

  @override
  State<PlaySolo> createState() => _PlaySoloState();
}

class _PlaySoloState extends State<PlaySolo> {
  final TextEditingController _controller = TextEditingController();

  Map<String, dynamic> guesses = {'gameId': '', 'secret': '', 'guesses': []};

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

    if (position == 4) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
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
                onTap: () {
                  String secret = _controller.text;
                  _controller.text = '';
                  playCheck(secret);
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
