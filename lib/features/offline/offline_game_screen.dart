import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/l10n.dart';
import '../../core/locale_controller.dart';
import '../../core/theme.dart';
import '../../widgets/ui.dart';
import 'runner_engine.dart';
import 'runner_sprites.dart';

const _bestScoreKey = 'offline_runner_best';

/// «Internet yo‘q»: a tiny jumping-dinosaur game to pass the time while the
/// connection is down. Works without any network; the record is kept locally.
class OfflineGameScreen extends ConsumerStatefulWidget {
  const OfflineGameScreen({super.key});

  /// Opens the game on top of the current screen (no router involved, so it
  /// works from any role and any state, signed in or not).
  static Future<void> open(BuildContext context) => Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (_) => const OfflineGameScreen()));

  @override
  ConsumerState<OfflineGameScreen> createState() => _OfflineGameScreenState();
}

class _OfflineGameScreenState extends ConsumerState<OfflineGameScreen>
    with SingleTickerProviderStateMixin {
  late final RunnerGame _game;
  late final Ticker _ticker;
  final _frame = ValueNotifier<int>(0);
  final _focus = FocusNode();
  Duration _last = Duration.zero;
  double _worldWidth = 400;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(sharedPreferencesProvider);
    _game = RunnerGame(bestScore: prefs.getInt(_bestScoreKey) ?? 0);
    _ticker = createTicker(_onTick)
      ..muted = true
      ..start();
  }

  void _onTick(Duration elapsed) {
    final dt =
        (elapsed - _last).inMicroseconds / Duration.microsecondsPerSecond;
    _last = elapsed;
    final before = _game.phase;
    _game.step(dt, _worldWidth);
    _frame.value++;
    if (before == RunnerPhase.running && _game.phase == RunnerPhase.over) {
      if (_game.newRecord) {
        ref
            .read(sharedPreferencesProvider)
            .setInt(_bestScoreKey, _game.bestScore);
      }
      HapticFeedback.lightImpact();
      _sync();
    }
  }

  /// The clock only ticks while the dinosaur runs: no frames (and no battery
  /// use) on the start and game-over panels.
  void _sync() {
    _ticker.muted = _game.phase != RunnerPhase.running;
    _frame.value++;
    setState(() {});
  }

  void _jump() {
    final before = _game.phase;
    _game.jump();
    if (before != _game.phase) _sync();
  }

  void _again() {
    _game.restart();
    _sync();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _frame.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final over = _game.phase == RunnerPhase.over;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.offlineGameTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpace.s4),
          children: [
            Text(
              l10n.offlineGameHint,
              style: AppText.body.copyWith(color: colors.inkSoft),
            ),
            const SizedBox(height: AppSpace.s4),
            ValueListenableBuilder<int>(
              valueListenable: _frame,
              builder: (_, _, _) => Row(
                children: [
                  Expanded(
                    child: _ScoreTile(
                      label: l10n.offlineGameScore,
                      value: _game.score,
                    ),
                  ),
                  const SizedBox(width: AppSpace.tileGap),
                  Expanded(
                    child: _ScoreTile(
                      label: l10n.offlineGameBest,
                      value: _game.bestScore,
                      icon: LucideIcons.trophy,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.s4),
            Focus(
              focusNode: _focus,
              autofocus: true,
              onKeyEvent: (_, event) {
                final isJumpKey =
                    event.logicalKey == LogicalKeyboardKey.space ||
                    event.logicalKey == LogicalKeyboardKey.arrowUp;
                if (event is KeyDownEvent && isJumpKey) {
                  over ? _again() : _jump();
                  return KeyEventResult.handled;
                }
                return KeyEventResult.ignored;
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (_) => over ? null : _jump(),
                  child: Container(
                    key: const Key('game-area'),
                    height: AppSize.gamePanel,
                    decoration: BoxDecoration(
                      color: colors.surfaceMuted,
                      border: Border.all(color: colors.border),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: LayoutBuilder(
                      builder: (_, box) {
                        final scale = box.maxHeight / RunnerWorld.worldHeight;
                        _worldWidth = box.maxWidth / scale;
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            CustomPaint(
                              painter: _RunnerPainter(_game, _frame, colors),
                            ),
                            if (_game.phase == RunnerPhase.ready)
                              _Overlay(title: l10n.offlineGameStart),
                            if (over)
                              _Overlay(
                                title: l10n.offlineGameOver,
                                subtitle: _game.newRecord
                                    ? l10n.offlineGameNewRecord
                                    : null,
                                action: PrimaryButton(
                                  label: l10n.offlineGameAgain,
                                  icon: LucideIcons.rotateCcw,
                                  onPressed: _again,
                                  height: AppSize.button,
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreTile extends StatelessWidget {
  const _ScoreTile({required this.label, required this.value, this.icon});

  final String label;
  final int value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Panel(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.s4,
        vertical: AppSpace.s3,
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: AppSize.iconMd, color: colors.brandStrong),
            const SizedBox(width: AppSpace.s2),
          ],
          Expanded(
            child: Text(
              label,
              style: AppText.label.copyWith(color: colors.inkMuted),
            ),
          ),
          Text(
            '$value'.padLeft(5, '0'),
            key: Key('score-$label'),
            style: AppText.code.copyWith(color: colors.ink),
          ),
        ],
      ),
    );
  }
}

class _Overlay extends StatelessWidget {
  const _Overlay({required this.title, this.subtitle, this.action});

  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      color: colors.surfaceMuted.withValues(alpha: 0.78),
      padding: const EdgeInsets.all(AppSpace.s4),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: AppText.heading.copyWith(color: colors.ink),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpace.s1),
            Text(
              subtitle!,
              style: AppText.bodyStrong.copyWith(color: colors.brandStrong),
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: AppSpace.s3),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppSize.gamePanel),
              child: action,
            ),
          ],
        ],
      ),
    );
  }
}

class _RunnerPainter extends CustomPainter {
  _RunnerPainter(this.game, Listenable repaint, this.colors)
    : super(repaint: repaint);

  final RunnerGame game;
  final AppColors colors;

  static final _paths = <List<String>, ui.Path>{};
  static ui.Path _path(List<String> rows) => _paths.putIfAbsent(rows, () {
    final path = ui.Path();
    for (var y = 0; y < rows.length; y++) {
      for (var x = 0; x < rows[y].length; x++) {
        if (rows[y][x] == '#') {
          path.addRect(
            Rect.fromLTWH(
              x * RunnerWorld.cell,
              y * RunnerWorld.cell,
              RunnerWorld.cell,
              RunnerWorld.cell,
            ),
          );
        }
      }
    }
    return path;
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.height / RunnerWorld.worldHeight;
    canvas.scale(scale);

    final ground = Paint()
      ..color = colors.inkMuted
      ..strokeWidth = 1.5;
    canvas.drawLine(
      const Offset(0, RunnerWorld.groundY),
      Offset(size.width / scale, RunnerWorld.groundY),
      ground,
    );
    // Pebbles scroll with the ground.
    final pebble = Paint()..color = colors.border;
    for (var x = -game.groundOffset % 90; x < size.width / scale; x += 90) {
      canvas.drawRect(Rect.fromLTWH(x, RunnerWorld.groundY + 8, 10, 2), pebble);
      canvas.drawRect(
        Rect.fromLTWH(x + 46, RunnerWorld.groundY + 16, 5, 2),
        pebble,
      );
    }

    final cactusPaint = Paint()..color = colors.success;
    for (final c in game.cacti) {
      for (var i = 0; i < c.count; i++) {
        canvas.save();
        canvas.translate(
          c.x + i * (RunnerWorld.cactusWidth + 2),
          RunnerWorld.groundY - RunnerWorld.cactusHeight,
        );
        canvas.drawPath(_path(cactus), cactusPaint);
        canvas.restore();
      }
    }

    final stepFrame = game.onGround && (game.runTime * 10).floor().isOdd;
    final legs = stepFrame ? dinoLegsB : dinoLegsA;
    canvas.save();
    canvas.translate(RunnerWorld.playerX, game.playerY);
    canvas.drawPath(_path(dinoIdle), Paint()..color = colors.ink);
    canvas.translate(0, dinoIdle.length * RunnerWorld.cell);
    canvas.drawPath(_path(legs), Paint()..color = colors.ink);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_RunnerPainter old) => old.colors != colors;
}
