import 'package:flutter/material.dart';

class CreateRoom extends StatefulWidget {
  const CreateRoom({super.key});

  @override
  State<CreateRoom> createState() => _CreateRoomState();
}

class _CreateRoomState extends State<CreateRoom> {
  String? selectedValue; // Stores the selected item
  List<String> items = ['Option 1', 'Option 2', 'Option 3', 'Option 4'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          Text('Challenge your friend', style: TextStyle(fontSize: 18),),
          Row(
            mainAxisAlignment: MainAxisAlignment
                .spaceBetween, // Space between children horizontally
            crossAxisAlignment:
                CrossAxisAlignment.center, // Center children vertically
            children: [
              SizedBox(
                height: 100,
                width: 150,
                child: TextField(
                  decoration: InputDecoration(hintText: 'Enter 4 digits 0 - 9'),
                ),
              ),
              SizedBox(
                width: 145,
                height: 50,
                child: DropdownButton<String>(
                  hint: Text("Max minutes"),
                  value: selectedValue, // Current selected value
                  onChanged: (newValue) {
                    setState(() {
                      selectedValue = newValue;
                    });
                  },
                  items: items.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                ),
              ),
            ],
          )
        ]),
      ),
    );
  }
}
