import 'package:flutter/material.dart';

class PlayBoard extends StatefulWidget {
  const PlayBoard({super.key});

  @override
  State<PlayBoard> createState() => _PlayBoardState();
}

class _PlayBoardState extends State<PlayBoard> {
  bool secretSubmitted = false;
  bool hideText = false;

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
            DataTable(
              columnSpacing: 20,
              headingRowColor: WidgetStateProperty.all(Colors.grey.shade300),
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
          ],
        ),
      ),
    );
  }
}
