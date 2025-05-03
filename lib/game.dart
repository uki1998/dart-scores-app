import 'package:flutter/material.dart';
import 'player_selection.dart';
import 'checkout.dart';

class _GameSnapshot {
  final int p1Score;
  final int p2Score;
  final int p1Sets;
  final int p2Sets;
  final bool isP1Turn;
  final int? lastP1Score;
  final int? lastP2Score;

  _GameSnapshot({
    required this.p1Score,
    required this.p2Score,
    required this.p1Sets,
    required this.p2Sets,
    required this.isP1Turn,
    this.lastP1Score,
    this.lastP2Score,
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

  List<int> player1Scores = [];
  List<int> player2Scores = [];

  double get player1Snitt {
    if (player1Scores.isEmpty) return 0;
    return player1Scores.reduce((a, b) => a + b) / player1Scores.length;
  }

  double get player2Snitt {
    if (player2Scores.isEmpty) return 0;
    return player2Scores.reduce((a, b) => a + b) / player2Scores.length;
  }

  int player1Sets = 0;
  int player2Sets = 0;

  bool isPlayer1Turn = true;
  String currentInput = '';

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
        lastP1Score: isPlayer1Turn ? enteredScore : null,
        lastP2Score: !isPlayer1Turn ? enteredScore : null,
      ),
    );

    setState(() {
      if (isPlayer1Turn) {
        if (enteredScore <= player1Score) {
          if (player1Score - enteredScore > 0) {
            player1Scores.add(enteredScore);
            player1Score -= enteredScore;
            isPlayer1Turn = false;
          } else if (player1Score - enteredScore == 0) {
            player1Scores.add(enteredScore);
            player1Score = 0;
            player1Sets++;
            _checkForWin();
            player1Score = widget.startingScore;
            player2Score = widget.startingScore;
            player1Scores.clear();
            player2Scores.clear();
          } else {
            currentInput = '';
            return;
          }
        }
      } else {
        if (enteredScore <= player2Score) {
          if (player2Score - enteredScore > 0) {
            player2Scores.add(enteredScore);
            player2Score -= enteredScore;
            isPlayer1Turn = true;
          } else if (player2Score - enteredScore == 0) {
            player2Scores.add(enteredScore);
            player2Score = 0;
            player2Sets++;
            _checkForWin();
            player1Score = widget.startingScore;
            player2Score = widget.startingScore;
            player1Scores.clear();
            player2Scores.clear();
          } else {
            currentInput = '';
            return;
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

      if (last.lastP1Score != null && player1Scores.isNotEmpty) {
        player1Scores.removeLast();
      }
      if (last.lastP2Score != null && player2Scores.isNotEmpty) {
        player2Scores.removeLast();
      }
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
                      player1Scores.clear();
                      player2Scores.clear();
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
              Text(
                'BÄST AV ${widget.bestOfSets} SET',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPlayerColumn(widget.player1.gameImagePath),
                  _buildPlayerColumn(widget.player2.gameImagePath),
                ],
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildScoreColumn(
                    widget.player1.name,
                    player1Score,
                    player1Sets,
                    player1Snitt,
                    isPlayer1Turn,
                  ),
                  _buildScoreColumn(
                    widget.player2.name,
                    player2Score,
                    player2Sets,
                    player2Snitt,
                    !isPlayer1Turn,
                  ),
                ],
              ),
              SizedBox(height: 20),
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

  Widget _buildScoreColumn(
    String name,
    int score,
    int sets,
    double snitt,
    bool isActive,
  ) {
    return Column(
      children: [
        Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        Text('POÄNG: $score', style: TextStyle(fontSize: 16)),
        Text('SET: $sets', style: TextStyle(fontSize: 16)),
        Text(
          'SNITT: ${snitt.toStringAsFixed(1)}',
          style: TextStyle(fontSize: 16),
        ),
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
