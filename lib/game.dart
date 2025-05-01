import 'package:flutter/material.dart';
import 'player_selection.dart';
import 'checkout.dart';

class _GameSnapshot {
  final int p1Score;
  final int p2Score;
  final int p1Sets;
  final int p2Sets;
  final bool isP1Turn;

  _GameSnapshot({
    required this.p1Score,
    required this.p2Score,
    required this.p1Sets,
    required this.p2Sets,
    required this.isP1Turn,
  });
}

class Game extends StatefulWidget {
  final Player player1;
  final Player player2;
  final int startingScore;
  final int bestOfSets;

  Game({
    required this.player1,
    required this.player2,
    required this.startingScore,
    required this.bestOfSets,
  });

  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> {
  late int player1Score;
  late int player2Score;

  int player1Sets = 0;
  int player2Sets = 0;

  bool isPlayer1Turn = true;
  String currentInput = '';

  int? prevPlayer1Score;
  int? prevPlayer2Score;
  int? prevPlayer1Sets;
  int? prevPlayer2Sets;
  bool? prevIsPlayer1Turn;

  int _currentPlayerScore() {
    return isPlayer1Turn ? player1Score : player2Score;
  }

  List<_GameSnapshot> history = [];

  @override
  void initState() {
    super.initState();
    player1Score = widget.startingScore;
    player2Score = widget.startingScore;
  }

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
      }
    });
  }

  void handleEnter() {
    if (currentInput.isEmpty) return;

    int enteredScore = int.tryParse(currentInput) ?? 0;

    history.add(
      _GameSnapshot(
        p1Score: player1Score,
        p2Score: player2Score,
        p1Sets: player1Sets,
        p2Sets: player2Sets,
        isP1Turn: isPlayer1Turn,
      ),
    );

    setState(() {
      // Save previous state before making changes
      prevPlayer1Score = player1Score;
      prevPlayer2Score = player2Score;
      prevPlayer1Sets = player1Sets;
      prevPlayer2Sets = player2Sets;
      prevIsPlayer1Turn = isPlayer1Turn;

      if (isPlayer1Turn) {
        if (enteredScore <= player1Score) {
          player1Score -= enteredScore;
          if (player1Score == 0) {
            player1Sets++;
            _checkForWin();
            player1Score = widget.startingScore;
            player2Score = widget.startingScore;
          } else {
            isPlayer1Turn = false;
          }
        }
      } else {
        if (enteredScore <= player2Score) {
          player2Score -= enteredScore;
          if (player2Score == 0) {
            player2Sets++;
            _checkForWin();
            player1Score = widget.startingScore;
            player2Score = widget.startingScore;
          } else {
            isPlayer1Turn = true;
          }
        }
      }

      currentInput = '';
    });
  }

  void handleUndo() {
    if (history.isEmpty) return;

    final last = history.removeLast();

    setState(() {
      player1Score = last.p1Score;
      player2Score = last.p2Score;
      player1Sets = last.p1Sets;
      player2Sets = last.p2Sets;
      isPlayer1Turn = last.isP1Turn;
      currentInput = '';
    });
  }

  void _checkForWin() {
    int neededSets = (widget.bestOfSets / 2).ceil();

    if (player1Sets == neededSets || player2Sets == neededSets) {
      String winner =
          player1Sets > player2Sets ? widget.player1.name : widget.player2.name;

      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: Text('$winner VANN!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      player1Sets = 0;
                      player2Sets = 0;
                      player1Score = widget.startingScore;
                      player2Score = widget.startingScore;
                      isPlayer1Turn = true;
                    });
                  },
                  child: Text('NY MATCH'),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('MATCH')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Show match settings
              Text(
                'BÄST AV ${widget.bestOfSets} SET',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),

              // Player images
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPlayerColumn(widget.player1.gameImagePath),
                  _buildPlayerColumn(widget.player2.gameImagePath),
                ],
              ),

              SizedBox(height: 30),

              // Show score + sets
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildScoreColumn(
                    widget.player1.name,
                    player1Score,
                    player1Sets,
                    isPlayer1Turn,
                  ),
                  _buildScoreColumn(
                    widget.player2.name,
                    player2Score,
                    player2Sets,
                    !isPlayer1Turn,
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Show current input
              Text(
                currentInput,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              if (_currentPlayerScore() <= 170)
                Text(
                  'CHECKOUT: ${checkoutSuggestions[_currentPlayerScore()] ?? '—'}',
                  style: TextStyle(fontSize: 18, color: Colors.blueAccent),
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
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: handleUndo,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.orange,
                  ),
                  child: Text('UNDO', style: TextStyle(fontSize: 20)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerColumn(String gameImagePath) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            gameImagePath,
            width: 100,
            height: 130,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildScoreColumn(String name, int score, int sets, bool isActive) {
    return Column(
      children: [
        Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        Text('POÄNG: $score', style: TextStyle(fontSize: 16)),
        Text('SET: $sets', style: TextStyle(fontSize: 16)),
        if (isActive)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text('DIN TUR', style: TextStyle(color: Colors.green)),
          ),
      ],
    );
  }

  Widget _buildNumberButton(int number) {
    return ElevatedButton(
      onPressed: () => handleNumberPress(number),
      child: Text('$number', style: TextStyle(fontSize: 24)),
      style: ElevatedButton.styleFrom(fixedSize: Size(80, 60)),
    );
  }

  Widget _buildActionButton(String label) {
    return ElevatedButton(
      onPressed: () => handleAction(label),
      child: Text(label, style: TextStyle(fontSize: 18)),
      style: ElevatedButton.styleFrom(
        fixedSize: Size(80, 60),
        backgroundColor: Colors.grey[600],
      ),
    );
  }
}
