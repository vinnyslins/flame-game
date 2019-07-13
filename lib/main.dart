import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'package:flame/game.dart';
import 'package:flame/flame.dart';
import 'package:flame/time.dart';

void main() async {
  final screenSize = await Flame.util.initialDimensions();
  final game = MyGame(screenSize);

  runApp(game.widget);

  Flame.util.addGestureRecognizer(TapGestureRecognizer()
    ..onTapUp = (TapUpDetails evt) {
      game.tapUp();
    }
    ..onTapDown = (TapDownDetails evt) {
      game.tapDown();
    }
  );
}

class MyGame extends Game {
  static const double PLAYER_SPEED = 300;
  static const double ENEMY_SPEED = 100;
  static final Paint white = Paint()..color = Color(0xFFFFFFFF);
  static final Paint black = Paint()..color = Color(0xFF000000);

  Size _screenSize;
  Rect _player;
  Rect _background;

  List<Rect> _enemies = [];

  int playerDirection = 1;
  bool playerMoving = true;

  Random random = Random();
  Timer _enemyCreator;

  MyGame(this._screenSize) {
    _background = Rect.fromLTWH(0, 0, _screenSize.width, _screenSize.height);
    _player = Rect.fromLTWH(_screenSize.width / 2 - 25, 500, 50, 50);

    _enemyCreator = Timer(2, repeat: true, callback: () {
      _enemies.add(Rect.fromLTWH((random.nextInt(_screenSize.width.toInt()) - 50).toDouble(), 0, 50, 50));
    });

    _enemyCreator.start();
  }

  void tapUp() {
    playerMoving = true;
  }

  void tapDown() {
    playerMoving = false;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(_background, white);
    canvas.drawRect(_player, black);

    _enemies.forEach((rect) {
      canvas.drawRect(rect, black);
    });
  }

  @override
  void update(double dt) {
    if (playerMoving) {
      _player = _player.translate(PLAYER_SPEED * dt * playerDirection, 0);

      if (_player.right >= _screenSize.width && playerDirection == 1) {
        playerDirection = -1;
      }

      if (_player.left <= 0 && playerDirection == -1) {
        playerDirection = 1;
      }
    }

    for (var i = 0; i < _enemies.length; i++) {
      final Rect rect = _enemies[i];
      _enemies[i] = rect.translate(0, ENEMY_SPEED * dt);

      if (rect.overlaps(_player)) {
        print('Morreu');
      }
    }

    _enemies.removeWhere((rect) => rect.top >= _screenSize.height || rect.overlaps(_player));

    _enemyCreator.update(dt);
  }
}
