import 'package:flutter/material.dart';

class Game extends StatefulWidget {
  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> {
  String currentInput = '';
  void handleNumberPress(int number) {
    setState(() {
      currentInput += number.toString();
    });
  }

  void handleAction(String action) {
    setState(() {
      if (action == '⌫' && currentInput.isNotEmpty) {
        currentInput = currentInput.substring(0, currentInput.length - 1);
      } else if (action == 'BUST') {
        currentInput = '';
        // You can add more logic later
      }
    });
  }

  void handleEnter() {
    print('Entered score: $currentInput');
    // Add logic to apply score
    setState(() {
      currentInput = '';
    });
  }

  Widget _buildNumberButton(int number) {
    return ElevatedButton(
      onPressed: () {
        handleNumberPress(number);
      },
      child: Text('$number', style: TextStyle(fontSize: 24)),
      style: ElevatedButton.styleFrom(fixedSize: Size(80, 60)),
    );
  }

  Widget _buildActionButton(String label) {
    return ElevatedButton(
      onPressed: () {
        handleAction(label);
      },
      child: Text(label, style: TextStyle(fontSize: 18)),
      style: ElevatedButton.styleFrom(
        fixedSize: Size(80, 60),
        backgroundColor: Colors.grey[600],
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Game')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Player pictures and names
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPlayerColumn('Uros', 'assets/images/uros.png'),
                  _buildPlayerColumn('Floris', 'assets/images/floris.png'),
                ],
              ),
              SizedBox(height: 30),

              // Show current input
              Text(
                currentInput,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),

              // Calculator layout
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [1, 2, 3].map(_buildNumberButton).toList(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [4, 5, 6].map(_buildNumberButton).toList(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [7, 8, 9].map(_buildNumberButton).toList(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton('BUST'),
                  _buildNumberButton(0),
                  _buildActionButton('⌫'),
                ],
              ),
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: handleEnter,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text('ENTER', style: TextStyle(fontSize: 20)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildPlayerColumn(String name, String imagePath) {
  return Column(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          imagePath,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
      ),
      SizedBox(height: 10),
      Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    ],
  );
}
