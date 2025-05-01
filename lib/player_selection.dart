import 'package:flutter/material.dart';
import 'game.dart';

class Player {
  final String name;
  final String imagePath;
  final String gameImagePath;

  Player({
    required this.name,
    required this.imagePath,
    required this.gameImagePath,
  });
}

class PlayerSelectionScreen extends StatefulWidget {
  @override
  _PlayerSelectionScreenState createState() => _PlayerSelectionScreenState();
}

class _PlayerSelectionScreenState extends State<PlayerSelectionScreen> {
  List<Player> players = [
    Player(
      name: 'UROS',
      imagePath: 'assets/images/uros.png',
      gameImagePath: 'assets/images/uros3.png',
    ),
    Player(
      name: 'FLORIS',
      imagePath: 'assets/images/floris.png',
      gameImagePath: 'assets/images/floris3.png',
    ),
  ];

  Player? player1;
  Player? player2;

  int selectedStartingScore = 501;
  int selectedBestOfSets = 3;

  void selectPlayer(Player selectedPlayer) {
    setState(() {
      if (player1 == null) {
        player1 = selectedPlayer;
      } else if (player2 == null && selectedPlayer != player1) {
        player2 = selectedPlayer;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('INSTÄLLNINGAR')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                ),
                itemCount: players.length,
                itemBuilder: (context, index) {
                  final player = players[index];
                  final isSelected = player == player1 || player == player2;
                  return GestureDetector(
                    onTap: () => selectPlayer(player),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? Colors.green : Colors.grey,
                          width: 5,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                player.imagePath,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 30),
              Text("POÄNG:", style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildOptionButton(301, selectedStartingScore, (value) {
                    setState(() => selectedStartingScore = value);
                  }),
                  SizedBox(width: 10),
                  _buildOptionButton(501, selectedStartingScore, (value) {
                    setState(() => selectedStartingScore = value);
                  }),
                ],
              ),
              SizedBox(height: 20),
              Text(
                "BÄST AV ANTAL SET:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                    [1, 3, 5].map((n) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: _buildOptionButton(n, selectedBestOfSets, (
                          value,
                        ) {
                          setState(() => selectedBestOfSets = value);
                        }),
                      );
                    }).toList(),
              ),
              SizedBox(height: 30),
              if (player1 != null && player2 != null)
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => Game(
                              player1: player1!,
                              player2: player2!,
                              startingScore: selectedStartingScore,
                              bestOfSets: selectedBestOfSets,
                            ),
                      ),
                    );
                  },
                  child: Text('STARTA MATCH'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(
    int value,
    int selectedValue,
    Function(int) onSelect,
  ) {
    return ElevatedButton(
      onPressed: () => onSelect(value),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            value == selectedValue ? Colors.green : Colors.grey[600],
      ),
      child: Text('$value'),
    );
  }
}
