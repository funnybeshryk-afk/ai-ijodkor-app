import 'dart:math';

/// Pure game logic of the offline runner (no Flutter): the Izlan student robot
/// jumps over bugs and stacks of books. World units are logical pixels; y grows downwards.
///
/// The world is [worldHeight] tall and as wide as the screen needs; the
/// painter scales it to the canvas.

/// World geometry and physics.
abstract final class RunnerWorld {
  static const worldHeight = 160.0;
  static const groundY = 132.0;

  /// Pixel size of one sprite cell.
  static const cell = 2.0;

  static const playerX = 36.0;
  static const playerWidth = 14 * cell;
  static const playerHeight = 14 * cell;

  static const obstacleWidth = 9 * cell;
  static const obstacleHeight = 12 * cell;

  /// Hitboxes are a bit smaller than sprites: a near miss counts as a miss.
  static const hitInset = 4.0;

  static const gravity = 1500.0;
  static const jumpVelocity = -470.0;

  static const startSpeed = 170.0;
  static const maxSpeed = 380.0;
  static const speedGain = 6.0; // per second

  /// Score points per world unit travelled.
  static const scorePerUnit = 0.1;

  static const minGap = 150.0;
  static const gapPerSpeed = 0.7;
  static const gapJitter = 160.0;
  static const maxCluster = 3;
}

enum RunnerPhase { ready, running, over }

class Obstacle {
  Obstacle(this.x, this.count, {this.isBug = false});

  double x;

  /// Obstacles standing next to each other (1–3).
  final int count;

  /// Look only: a bug or a stack of books (same size, same hitbox).
  final bool isBug;

  double get width => count * RunnerWorld.obstacleWidth + (count - 1) * 2;
}

class RunnerGame {
  RunnerGame({Random? random, this.bestScore = 0})
    : _random = random ?? Random();

  final Random _random;

  RunnerPhase phase = RunnerPhase.ready;
  int bestScore;

  double playerY = RunnerWorld.groundY - RunnerWorld.playerHeight;
  double _velocityY = 0;
  double speed = RunnerWorld.startSpeed;
  double _distance = 0;
  double groundOffset = 0;
  double runTime = 0;
  final obstacles = <Obstacle>[];
  int _spawned = 0;
  double _worldWidth = 400;
  double _nextGap = 0;

  /// Set when a run ended with a new record.
  bool newRecord = false;

  int get score => (_distance * RunnerWorld.scorePerUnit).floor();

  bool get onGround =>
      playerY >= RunnerWorld.groundY - RunnerWorld.playerHeight - 0.001;

  /// Tap / key press: start, jump, or (when over) nothing — restart is explicit.
  void jump() {
    if (phase == RunnerPhase.over) return;
    if (phase == RunnerPhase.ready) restart();
    if (onGround) _velocityY = RunnerWorld.jumpVelocity;
  }

  void restart() {
    phase = RunnerPhase.running;
    playerY = RunnerWorld.groundY - RunnerWorld.playerHeight;
    _velocityY = 0;
    speed = RunnerWorld.startSpeed;
    _distance = 0;
    runTime = 0;
    newRecord = false;
    obstacles.clear();
    _spawned = 0;
    _nextGap = _randomGap();
  }

  double _randomGap() =>
      RunnerWorld.minGap +
      speed * RunnerWorld.gapPerSpeed +
      _random.nextDouble() * RunnerWorld.gapJitter;

  /// Advance by [dt] seconds in a world [worldWidth] wide.
  void step(double dt, double worldWidth) {
    _worldWidth = worldWidth;
    if (phase != RunnerPhase.running) return;
    // Long frames (app paused) must not teleport the robot through an obstacle.
    final h = dt.clamp(0.0, 0.05);

    runTime += h;
    speed = min(RunnerWorld.maxSpeed, speed + RunnerWorld.speedGain * h);
    final dx = speed * h;
    _distance += dx;
    groundOffset = (groundOffset + dx) % 1000;

    _velocityY += RunnerWorld.gravity * h;
    playerY += _velocityY * h;
    final floor = RunnerWorld.groundY - RunnerWorld.playerHeight;
    if (playerY >= floor) {
      playerY = floor;
      _velocityY = 0;
    }

    for (final o in obstacles) {
      o.x -= dx;
    }
    obstacles.removeWhere((o) => o.x + o.width < -8);

    _nextGap -= dx;
    final lastRight = obstacles.isEmpty
        ? 0.0
        : obstacles.last.x + obstacles.last.width;
    if (_nextGap <= 0 && lastRight < _worldWidth) {
      obstacles.add(
        Obstacle(
          _worldWidth + 8,
          1 + _random.nextInt(RunnerWorld.maxCluster),
          isBug: _spawned.isOdd,
        ),
      );
      _spawned++;
      _nextGap = _randomGap();
    }

    if (_hitsObstacle()) {
      phase = RunnerPhase.over;
      if (score > bestScore) {
        bestScore = score;
        newRecord = true;
      }
    }
  }

  bool _hitsObstacle() {
    const inset = RunnerWorld.hitInset;
    final left = RunnerWorld.playerX + inset;
    final right = RunnerWorld.playerX + RunnerWorld.playerWidth - inset;
    final bottom = playerY + RunnerWorld.playerHeight - inset;
    final top = playerY + inset;
    final obstacleTop =
        RunnerWorld.groundY - RunnerWorld.obstacleHeight + inset;
    for (final o in obstacles) {
      final cl = o.x + inset;
      final cr = o.x + o.width - inset;
      if (right > cl &&
          left < cr &&
          bottom > obstacleTop &&
          top < RunnerWorld.groundY) {
        return true;
      }
    }
    return false;
  }
}
