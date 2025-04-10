import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:png_game/classes/data.dart';
import 'package:png_game/classes/play_board_classes.dart';
import 'package:png_game/services/playboard_provider.dart';
import 'package:png_game/services/socket_service.dart';
import 'package:png_game/storage/saved_data.dart';
import 'package:provider/provider.dart';

class PlaySolo extends StatefulWidget {
  const PlaySolo({super.key});

  @override
  State<PlaySolo> createState() => _PlaySoloState();
}

class _PlaySoloState extends State<PlaySolo> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: () {
              PlayBoardClasses().setChatValue('');
              PlayBoardClasses().setGuesses([]);
              PlayBoardClasses().setIsSubmitted(false);
              PlayBoardClasses().setMySecret('');
              PlayBoardClasses().setShowSecret(false);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
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
                rows: const [
                  DataRow(
                    cells: [
                      DataCell(Text('1')), // Here's your attempt number
                      DataCell(Text('1589')),
                      DataCell(Text('2')),
                      DataCell(Text('3')),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('1')), // Here's your attempt number
                      DataCell(Text('1589')),
                      DataCell(Text('2')),
                      DataCell(Text('3')),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('1')), // Here's your attempt number
                      DataCell(Text('1589')),
                      DataCell(Text('2')),
                      DataCell(Text('3')),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('1')), // Here's your attempt number
                      DataCell(Text('1589')),
                      DataCell(Text('2')),
                      DataCell(Text('3')),
                    ],
                  ),
                ]),
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
                onTap: () {},
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
