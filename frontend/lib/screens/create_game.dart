import 'package:flutter/material.dart';

class CreateGames extends StatefulWidget {
  const CreateGames({super.key});

  @override
  State<CreateGames> createState() => _CreateGamesState();
}

class _CreateGamesState extends State<CreateGames> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: ListTile(
          title: Text('Create New Game'),
          subtitle: Text('Set up your game room'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
         
          children: [
             Divider(),
             SizedBox(height: 12,),
            Container(
              padding: const EdgeInsets.all(12.0),
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Room Name', style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w500),),
                  Spacer(),
                  TextField(
  
                      decoration: InputDecoration(
                      hintText: 'Enter room name..',
                      filled: true,
                      // background color matching a light gray tone (adjust if you want a different color)
                      fillColor: Colors.grey.shade200,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                     // remove visible borders but preserve rounded corners
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                     ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                    ),
                    ),
                  
                  ),
                ],
              ),
            ),

            Container(
                padding: const EdgeInsets.all(12.0),
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
            
            )

          ],
        ),
      ),
    );
  }
}