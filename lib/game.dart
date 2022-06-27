import 'dart:async';

import 'package:flutter/material.dart';
import 'package:snake/control_panel.dart';
import 'package:snake/direction.dart';
import 'package:snake/piece.dart';
import 'dart:math';

class GamePage extends StatefulWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  int? upperBoundX, upperBoundY, lowerBoundX, lowerBoundY;
  double? screenWidth, screenHeight;
  int? step = 30;
  int length = 5;

  List<Offset> positions = [];
  Direction direction = Direction.right;

  Timer? timer;

  Offset? foodPosition;
  Piece? food;

  int score = 0;
  double speed = .50;
  void changeSpeed() {
    if (timer != null && timer!.isActive) {
      timer!.cancel();
    }
    timer = Timer.periodic(Duration(milliseconds: 200 ~/ speed), (timer) {
      setState(() {});
    });
  }

  Widget getControls() {
    return ControlPanel(onTapped: (Direction newDirection) {
      direction = newDirection;
    });
  }

  Direction getRandomDirection() {
    int val = Random().nextInt(4);
    direction = Direction.values[val];
    return direction;
  }

  void restart() {
    length = 5;
    score = 0;
    speed = 1;
    positions = [];
    direction = getRandomDirection();
    changeSpeed();
  }

  @override
  void initState() {
    super.initState();
    restart();
  }

  int? getNearestTens(int num) {
    int output;
    output = (num ~/ step!) * step!;
    if (output == 0) {
      output += step!;
    }
    return output;
  }

  Offset getRandomPositions() {
    Offset position;
    int posX = Random().nextInt(upperBoundX!) + lowerBoundX!;
    int posY = Random().nextInt(upperBoundY!) + lowerBoundY!;
    position = Offset(
        getNearestTens(posX)!.toDouble(), getNearestTens(posY)!.toDouble());
    return position;
  }

  void draw() async {
    if (positions.isEmpty) {
      positions.add(getRandomPositions());
    }
    while (length > positions.length) {
      positions.add(positions[positions.length - 1]);
    }
    for (var i = positions.length - 1; i > 0; i--) {
      positions[i] = positions[i - 1];
    }
    positions[0] = await getNextPosition(positions[0]);
  }

  bool detectCollision(Offset position) {
    if (position.dx >= upperBoundX! && direction == Direction.right) {
      return true;
    } else if (position.dx <= lowerBoundX! && direction == Direction.left) {
      return true;
    } else if (position.dy >= upperBoundY! && direction == Direction.down) {
      return true;
    } else if (position.dy <= lowerBoundX! && direction == Direction.up) {
      return true;
    }
    return false;
  }

  void showGameOverDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 243, 23, 96),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.blue, width: 3.0),
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          title: Text(
            "Game Over",
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            "Your Game is Over.But you played well.Your Score is " +
                score.toString() +
                ".",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                restart();
              },
              child: Text(
                "Restart",
                style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            )
          ],
        );
      },
    );
  }

  Future<Offset> getNextPosition(Offset position) async {
    Offset? nextPosition;

    if (direction == Direction.right) {
      nextPosition = Offset(position.dx + step!, position.dy);
    } else if (direction == Direction.left) {
      nextPosition = Offset(position.dx - step!, position.dy);
    } else if (direction == Direction.up) {
      nextPosition = Offset(position.dx, position.dy - step!);
    } else if (direction == Direction.down) {
      nextPosition = Offset(position.dx, position.dy + step!);
    }

    if (detectCollision(position) == true) {
      if (timer != null && timer!.isActive) {
        timer!.cancel();
      }
      await Future.delayed(
          Duration(milliseconds: 200), () => showGameOverDialog());
      return position;
    }
    return nextPosition!;
  }

  void drawFood() {
    if (foodPosition == null) {
      foodPosition = getRandomPositions();
    }

    if (foodPosition == positions[0]) {
      length++;
      score = score + 5;
      speed = speed + 0.20;
      foodPosition = getRandomPositions();
    }
    food = Piece(
      posX: foodPosition!.dx.toInt(),
      posY: foodPosition!.dy.toInt(),
      size: step,
      color: Color.fromARGB(255, 255, 139, 7),
      isAnimated: true,
    );
  }

  List<Piece> getPieces() {
    final pieces = <Piece>[];
    draw();
    drawFood();
    for (var i = 0; i < length; ++i) {
      if (i >= positions.length) {
        continue;
      }

      pieces.add(Piece(
        posX: positions[i].dx.toInt(),
        posY: positions[i].dy.toInt(),
        size: step,
        color: i.isEven ? Color.fromARGB(255, 43, 1, 122) : Color.fromARGB(255, 7, 197, 255),
        isAnimated: false,
      ));
    }

    return pieces;
  }

  Widget getScore() {
    return Positioned(
        top: 80.0,
        right: 50.0,
        child: Text(
          "Score:" + score.toString(),
          style: TextStyle(fontSize: 30, color: Colors.white),
        ));
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    lowerBoundY = step;
    lowerBoundX = step;

    upperBoundY = getNearestTens(screenHeight!.toInt() - step!);
    upperBoundX = getNearestTens(screenWidth!.toInt() - step!);
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Color.fromARGB(115, 36, 35, 35),
          child: Stack(
            children: [
              Stack(
                children: getPieces(),
              ),
              getControls(),
              food!,
              getScore(),
            ],
          ),
        ),
      ),
    );
  }
}
