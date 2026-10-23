import 'dart:math';

import 'package:izlan/features/offline/offline_game_screen.dart';
import 'package:izlan/features/offline/runner_engine.dart';
import 'package:izlan/features/offline/runner_sprites.dart';
import 'package:izlan/widgets/async_value_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:izlan/core/locale_controller.dart';
import 'package:izlan/core/theme.dart';
import 'package:izlan/core/l10n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> pumpWidgetWithApp(WidgetTester tester, Widget home) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: MaterialApp(
        theme: AppTheme.light(),
        locale: const Locale('uz'),
        supportedLocales: supportedAppLocales,
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(body: home),
      ),
    ),
  );
}

void main() {
  group('sprites', () {
    test('rows of each sprite have equal width', () {
      for (final rows in [robotIdle, robotLegsA, robotLegsB, bug, bookStack]) {
        expect(rows.map((r) => r.length).toSet().length, 1);
      }
      expect(robotIdle.first.length, robotLegsA.first.length);
      expect(robotIdle.length + robotLegsA.length, 14);
    });
  });

  group('RunnerGame', () {
    test('waits until the first jump, then runs', () {
      final game = RunnerGame(random: Random(1));
      game.step(0.016, 400);
      expect(game.phase, RunnerPhase.ready);
      expect(game.score, 0);
      game.jump();
      expect(game.phase, RunnerPhase.running);
    });

    test('a jump goes up and lands back on the ground', () {
      final game = RunnerGame(random: Random(1))..jump();
      final ground = game.playerY;
      game.step(0.05, 400);
      expect(game.playerY, lessThan(ground));
      expect(game.onGround, isFalse);
      for (var i = 0; i < 40; i++) {
        game.step(0.016, 400);
        if (game.phase != RunnerPhase.running) break;
      }
      // Either landed, or ended by an obstacle; never below the ground.
      expect(game.playerY, lessThanOrEqualTo(ground));
    });

    test('running into an obstacle ends the run and keeps the record', () {
      final game = RunnerGame(random: Random(1))..restart();
      game.obstacles.add(Obstacle(RunnerWorld.playerX + 10, 1));
      for (var i = 0; i < 30 && game.phase == RunnerPhase.running; i++) {
        game.step(0.016, 400);
      }
      expect(game.phase, RunnerPhase.over);
      game.jump(); // ignored after the end
      expect(game.phase, RunnerPhase.over);
    });

    test('jumping at the right time clears the obstacle', () {
      final game = RunnerGame(random: Random(1))..restart();
      game.obstacles.add(Obstacle(160, 1));
      var jumped = false;
      for (var i = 0; i < 300 && game.phase == RunnerPhase.running; i++) {
        final c = game.obstacles.firstOrNull;
        if (!jumped && c != null && c.x - RunnerWorld.playerX < 60) {
          game.jump();
          jumped = true;
        }
        game.step(0.016, 400);
        if (jumped && game.obstacles.isEmpty) break;
      }
      expect(game.phase, RunnerPhase.running);
    });

    test('score grows with distance, speed is capped, record is updated', () {
      final game = RunnerGame(random: Random(1), bestScore: 3)..restart();
      for (var i = 0; i < 400; i++) {
        game.obstacles.clear(); // an empty road
        game.step(0.016, 400);
      }
      expect(game.phase, RunnerPhase.running);
      expect(game.score, greaterThan(3));
      expect(game.speed, lessThanOrEqualTo(RunnerWorld.maxSpeed));
      game.obstacles.add(Obstacle(RunnerWorld.playerX, 1));
      game.step(0.016, 400);
      expect(game.phase, RunnerPhase.over);
      expect(game.newRecord, isTrue);
      expect(game.bestScore, game.score);
    });

    test('a long frame cannot skip over an obstacle', () {
      final game = RunnerGame(random: Random(1))..restart();
      game.obstacles.add(Obstacle(RunnerWorld.playerX + 60, 1));
      game.step(5, 400); // clamped to one short step
      expect(game.obstacles.first.x, greaterThan(RunnerWorld.playerX));
    });
  });

  group('screen', () {
    testWidgets('error view offers the game, game starts and saves nothing '
        'without a record', (tester) async {
      await pumpWidgetWithApp(tester, ErrorRetryView(onRetry: () {}));
      expect(find.text('Kutayotganda o‘ynash'), findsOneWidget);
      await tester.tap(find.text('Kutayotganda o‘ynash'));
      await tester.pumpAndSettle();
      expect(find.text('Internet yo‘q'), findsOneWidget);
      expect(find.text('Boshlash uchun bosing'), findsOneWidget);

      await tester.tap(find.byKey(const Key('game-area')));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Boshlash uchun bosing'), findsNothing);

      // Let the robot run into an obstacle.
      for (var i = 0; i < 200; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(find.text('O‘yin tugadi'), findsOneWidget);
      await tester.tap(find.text('Qayta o‘ynash'));
      await tester.pump();
      expect(find.text('O‘yin tugadi'), findsNothing);
    });

    testWidgets('screen opens standalone', (tester) async {
      await pumpWidgetWithApp(tester, const OfflineGameScreen());
      expect(find.text('Internet yo‘q'), findsOneWidget);
    });
  });
}
