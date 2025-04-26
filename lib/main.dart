import 'package:flutter/material.dart';
import 'player_selection.dart'; // <-- import here

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UROS VS. FLORIS',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: StartNewGameScreen(),
    );
  }
}

class StartNewGameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dart Scores')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PlayerSelectionScreen()),
            );
          },
          child: Text('Start New Game'),
        ),
      ),
    );
  }
}
