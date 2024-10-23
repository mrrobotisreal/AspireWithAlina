import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/experimental.dart';
import 'package:flame/events.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../navigation/side_navigation_menu.dart';

class Bullet extends SpriteAnimationComponent
    with HasGameReference<SpaceShooterGame> {
  Bullet({
    super.position,
  }) : super(
          size: Vector2(30, 50),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    animation = await game.loadSpriteAnimation(
      'beams.png',
      SpriteAnimationData.sequenced(
        amount: 6,
        stepTime: .05,
        textureSize: Vector2.all(30),
      ),
    );

    add(
      RectangleHitbox(
        collisionType: CollisionType.passive,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.y += dt * -500;

    if (position.y < -height) {
      removeFromParent();
    }
  }
}

class Player extends SpriteAnimationComponent with HasGameRef<SpaceShooterGame>, CollisionCallbacks {
  late final SpawnComponent _bulletSpawner;

  Player() : super(
    size: Vector2(100, 150),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    animation = await game.loadSpriteAnimation(
      'player.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: .2,
        textureSize: Vector2(32, 48),
      ),
    );

    position = game.size / 2;

    _bulletSpawner = SpawnComponent(
      period: .2,
      selfPositioning: true,
      factory: (index) {
        return Bullet(
          position: position +
              Vector2(
                0,
                -height / 2,
              ),
        );
      },
      autoStart: false,
    );

    game.add(_bulletSpawner);

    add(RectangleHitbox());
  }

  void move(Vector2 delta) {
    position.add(delta);
  }

  void startShooting() {
    _bulletSpawner.timer.start();
  }

  void stopShooting() {
    _bulletSpawner.timer.stop();
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Enemy || other is Asteroid) {
      removeFromParent();
      other.removeFromParent();
      game.add(Explosion(position: position));
      game.onPlayerDestroyed();
    }
  }
}

class Enemy extends SpriteAnimationComponent
    with HasGameReference<SpaceShooterGame>, CollisionCallbacks {

  Enemy({
    super.position,
  }) : super(
          size: Vector2.all(enemySize),
          anchor: Anchor.center,
        );


  static const enemySize = 50.0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    animation = await game.loadSpriteAnimation(
      'enemy.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: .2,
        textureSize: Vector2.all(16),
      ),
    );

    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.y += dt * 300;

    if (position.y > game.size.y) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Bullet) {
      removeFromParent();
      other.removeFromParent();
      game.add(Explosion(position: position));
      game.onEnemyDestroyed();
    }
  }
}

class Asteroid extends SpriteAnimationComponent
    with HasGameReference<SpaceShooterGame>, CollisionCallbacks {

  Asteroid({
    super.position,
  }) : super(
          size: Vector2.all(asteroidSize),
          anchor: Anchor.center,
        );


  static const asteroidSize = 50.0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    animation = await game.loadSpriteAnimation(
      'asteroid.png',
      SpriteAnimationData.sequenced(
        amount: 8,
        stepTime: .1,
        textureSize: Vector2.all(160),
      ),
    );

    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.y += dt * 450;

    if (position.y > game.size.y) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Bullet) {
      removeFromParent();
      other.removeFromParent();
      game.add(AsteroidExplosion(position: position));
      game.onAsteroidDestroyed();
    }
  }
}

class Explosion extends SpriteAnimationComponent
    with HasGameReference<SpaceShooterGame> {
  Explosion({
    super.position,
  }) : super(
          size: Vector2.all(150),
          anchor: Anchor.center,
          removeOnFinish: true,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    animation = await game.loadSpriteAnimation(
      'explosion.png',
      SpriteAnimationData.sequenced(
        amount: 6,
        stepTime: 0.1,
        textureSize: Vector2.all(32),
        loop: false,
      ),
    );
  }
}

class AsteroidExplosion extends SpriteAnimationComponent
    with HasGameReference<SpaceShooterGame> {
  AsteroidExplosion({
    super.position,
  }) : super(
          size: Vector2.all(150),
          anchor: Anchor.center,
          removeOnFinish: true,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    animation = await game.loadSpriteAnimation(
      'asteroid_explosion.png',
      SpriteAnimationData.sequenced(
        amount: 6,
        stepTime: 0.1,
        textureSize: Vector2.all(40),
        loop: false,
      ),
    );
  }
}

class SpaceShooterGame extends FlameGame with PanDetector, HasCollisionDetection {
  SpaceShooterGame({
    this.onEnemyDestroyedCallback,
    this.onPlayerDestroyedCallback,
    this.onAsteroidDestroyedCallback,
  });

  late Player player;
  // ValueNotifier<int> remainingLives = ValueNotifier<int>(3);
  // ValueNotifier<int> enemiesDestroyed = ValueNotifier<int>(0);
  int remainingLives = 3;
  int enemiesDestroyed = 0;
  Function? onEnemyDestroyedCallback;
  Function? onPlayerDestroyedCallback;
  Function? onAsteroidDestroyedCallback;

  @override
  Future<void> onLoad() async {
    final parallax = await loadParallaxComponent(
      [
        ParallaxImageData('stars_0.png'),
        ParallaxImageData('stars_1.png'),
        ParallaxImageData('stars_2.png'),
      ],
      baseVelocity: Vector2(0, -5),
      repeat: ImageRepeat.repeat,
      velocityMultiplierDelta: Vector2(0, 5),
    );
    add(parallax);

    player = Player();
    add(player);

    add(
      SpawnComponent(
        factory: (index) {
          return Enemy();
        },
        period: 1,
        area: Rectangle.fromLTWH(0, 0, size.x, -Enemy.enemySize),
      ),
    );

    add(
      SpawnComponent(
        factory: (index) {
          return Asteroid();
        },
        period: 1,
        area: Rectangle.fromLTWH(0, 0, size.x, -Asteroid.asteroidSize),
      ),
    );
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    player.move(info.delta.global);
  }

  @override
  void onPanStart(DragStartInfo info) {
    player.startShooting();
  }

  @override
  void onPanEnd(DragEndInfo info) {
    player.stopShooting();
  }

  // Method to reset the player (e.g., after being destroyed)
  void resetPlayer() {
    player.position = Vector2(size.x / 2, size.y - 100);  // Reset to original position
    player.angle = 0;  // Reset rotation if needed
    add(player);  // Add the player back to the game
  }

  void onEnemyDestroyed() {
    enemiesDestroyed += 1;
    print('Enemies destroyed: ${enemiesDestroyed}');

    if (onEnemyDestroyedCallback != null) {
      onEnemyDestroyedCallback!();
    }
  }

  void onAsteroidDestroyed() {
    enemiesDestroyed += 3;
    print('Enemies destroyed: ${enemiesDestroyed}');

    if (onEnemyDestroyedCallback != null) {
      onEnemyDestroyedCallback!();
    }
  }

  void onPlayerDestroyed() {
    remainingLives -= 1;
    print('Remaining lives: ${remainingLives}');

    if (onPlayerDestroyedCallback != null) {
      onPlayerDestroyedCallback!();
    }
  }
}

class SpaceShooterScreen extends StatefulWidget {
  static const routeName = '/games/space-shooter';

  @override
  SpaceShooterScreenState createState() => SpaceShooterScreenState();
}

class SpaceShooterScreenState extends State<SpaceShooterScreen> {
  late SpaceShooterGame _spaceShooterGame;
  var _remainingLivesIcons = [
    Row(
      children: [
        Image(
          image: AssetImage('assets/images/player-sprite.png'),
        ),
        SizedBox(width: 10),
      ],
    ),
    Row(
      children: [
        Image(
          image: AssetImage('assets/images/player-sprite.png'),
        ),
        SizedBox(width: 10),
      ],
    ),
    Image(
      image: AssetImage('assets/images/player-sprite.png'),
    ),
  ];
  var enemiesDestroyed = 0;
  var remainingLives = 3;

  @override
  void initState() {
    super.initState();
    _spaceShooterGame = SpaceShooterGame(
      onEnemyDestroyedCallback: onEnemyDestroyedCallback,
      onPlayerDestroyedCallback: onPlayerDestroyedCallback,
    );  // Initialize the game
  }

  void onEnemyDestroyedCallback() {
    print('Callback called');
    setState(() {
      enemiesDestroyed = _spaceShooterGame.enemiesDestroyed;
    });
  }

  void onPlayerDestroyedCallback() {
    print('Callback called');
    setState(() {
      remainingLives = _spaceShooterGame.remainingLives;

      if (_spaceShooterGame.remainingLives == 2) {
        _remainingLivesIcons.removeLast();
      } else if (_spaceShooterGame.remainingLives == 1) {
        _remainingLivesIcons.removeLast();
      } else if (_spaceShooterGame.remainingLives == 0) {
        _remainingLivesIcons.removeLast();
      }
    });

    if (remainingLives == 0) {
      _showGameOverDialog(
        context,
        'You have no more lives left. Game over!',
      );
    }
  }

  void _showGameOverDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Game Over!',
            style: const TextStyle(
              fontFamily: 'Bauhaus',
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontFamily: 'Bauhaus',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                AppLocalizations.of(context)!.common_okayTitle,
                style: const TextStyle(
                  fontFamily: 'Bauhaus',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  enemiesDestroyed = 0;
                  _spaceShooterGame.enemiesDestroyed = 0;
                  remainingLives = 3;
                  _spaceShooterGame.remainingLives = 3;
                  _remainingLivesIcons = [
                    Row(
                      children: [
                        Image(
                          image: AssetImage('assets/images/player-sprite.png'),
                        ),
                        SizedBox(width: 10),
                      ],
                    ),
                    Row(
                      children: [
                        Image(
                          image: AssetImage('assets/images/player-sprite.png'),
                        ),
                        SizedBox(width: 10),
                      ],
                    ),
                    Image(
                      image: AssetImage('assets/images/player-sprite.png'),
                    ),
                  ];
                });
                Navigator.of(context).pop();
                _spaceShooterGame.resetPlayer();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: Text(
                'Play Again',
                style: const TextStyle(
                  fontFamily: 'Bauhaus',
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Color.fromARGB(150, 126, 126, 126),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: AppBar(
            elevation: 24,
            backgroundColor: Colors.blue,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              'Space Shooter',
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Bauhaus',
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                decorationStyle: TextDecorationStyle.solid,
                decorationColor: Colors.white,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.pushNamed(context, '/settings');
                },
              ),
            ],
            leading: Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              },
            ),
          ),
        ),
      ),
      drawer: const SideNavigationMenu(),
      body: Column(
        children: [
          Flexible(
            fit: FlexFit.tight,
            child: GameWidget(
                game: _spaceShooterGame,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 32.0,
            ),
            color: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Lives: ',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Bauhaus',
                      ),
                    ),
                    SizedBox(width: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _remainingLivesIcons,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Call the reset method on the game
                        _spaceShooterGame.resetPlayer();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: Text(
                        'Reset Player',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Bauhaus',
                        ),
                      ),
                    ),
                    SizedBox(width: 20), // Space between buttons
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          enemiesDestroyed = 0;
                          remainingLives = 3;
                          _remainingLivesIcons = [
                            Row(
                              children: [
                                Image(
                                  image: AssetImage('assets/images/player-sprite.png'),
                                ),
                                SizedBox(width: 10),
                              ],
                            ),
                            Row(
                              children: [
                                Image(
                                  image: AssetImage('assets/images/player-sprite.png'),
                                ),
                                SizedBox(width: 10),
                              ],
                            ),
                            Image(
                              image: AssetImage('assets/images/player-sprite.png'),
                            ),
                          ];
                        });
                        _spaceShooterGame.resetPlayer();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: Text(
                        'Reset Game',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Bauhaus',
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Enemies Destroyed: ',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Bauhaus',
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      '$enemiesDestroyed',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Bauhaus',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
