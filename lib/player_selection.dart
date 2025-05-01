import 'package:flutter/material.dart';
import 'game.dart';

class Player {
  final String imagePath;

  Player({required this.imagePath});
}

class PlayerSelectionScreen extends StatefulWidget {
  @override
  _PlayerSelectionScreenState createState() => _PlayerSelectionScreenState();
}

class _PlayerSelectionScreenState extends State<PlayerSelectionScreen> {
  List<Player> players = [
    Player(imagePath: 'assets/images/uros.png'),
    Player(imagePath: 'assets/images/floris.png'),
  ];

  Player? player1;
  Player? player2;

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
      appBar: AppBar(title: Text('Select Players')),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(20),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // two players side by side
                mainAxisSpacing: 300,
                crossAxisSpacing: 300,
              ),
              itemCount: players.length,
              itemBuilder: (context, index) {
                final player = players[index];
                final isSelected = player == player1 || player == player2;
                return GestureDetector(
                  onTap: () {
                    selectPlayer(player);
                  },
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
          ),
          if (player1 != null && player2 != null)
            Padding(
              padding: EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Game()),
                  );
                },
                child: Text('Start Game'),
              ),
            ),
        ],
      ),
    );
  }
}
