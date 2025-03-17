import 'package:flutter/material.dart';

class PlayBoard extends StatefulWidget {
  const PlayBoard({super.key});

  @override
  State<PlayBoard> createState() => _PlayBoardState();
}

class _PlayBoardState extends State<PlayBoard> {
  bool secretSubmitted = false;
  bool hideText = false;
  bool showMine = true;
  bool loggedIn = false;

  List<Map<String, String>> guesses = [
    {'guess': '1324', 'position': '2', 'number': '3'},
    {'guess': '1358', 'position': '2', 'number': '3'},
    {'guess': '1324', 'position': '2', 'number': '3'},
    {'guess': '1324', 'position': '2', 'number': '3'},
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            secretSubmitted
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        hideText = !hideText;
                      });
                    },
                    child: Align(
                      alignment:
                          Alignment.centerLeft, // Adjust alignment if needed
                      child: Container(
                        width: 60,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.grey.shade100,
                        ),
                        child: Center(
                          child: hideText ? const Text('****') : Text('1473'),
                        ), // Center text inside
                      ),
                    ),
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 35,
                        width: 150,
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Enter secret code',
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        color: Colors.green,
                        height: 35,
                        child: TextButton(
                            onPressed: () {
                              setState(() {
                                secretSubmitted = true;
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
                  onTap: () {
                    setState(() {
                      showMine = true;
                    });
                  },
                  child: Container(
                    width: 170,
                    color: showMine ? Colors.grey.shade200 : null,
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
                  onTap: () {
                    setState(() {
                      showMine = false;
                    });
                  },
                  child: Container(
                    width: 170,
                    color: !showMine ? Colors.grey.shade200 : null,
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
            showMine
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
                    rows: guesses.asMap().entries.map((entry) {
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
                    rows: guesses.asMap().entries.map((entry) {
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
                  onChanged: (value) {},

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
              Container(
                decoration: BoxDecoration(color: Colors.green),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Text('Submit'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
