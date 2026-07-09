import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../config/levels.dart';
import '../data/progress.dart';
import '../game/dokete_game.dart';

class GameScreen extends StatefulWidget {
  final int levelIndex; // 1始まり
  const GameScreen({super.key, required this.levelIndex});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late int levelIndex;
  late DoketeGame game;
  int gameId = 0; // GameWidget を作り直すためのキー

  @override
  void initState() {
    super.initState();
    levelIndex = widget.levelIndex;
    game = _build(levelIndex);
  }

  DoketeGame _build(int lv) {
    final g = DoketeGame(getLevel(lv));
    g.status.addListener(() {
      if (g.status.value == GameStatus.clear) {
        Progress.recordClear(lv);
      }
    });
    return g;
  }

  void _retry() => setState(() {
        gameId++;
        game = _build(levelIndex);
      });

  void _next() => setState(() {
        levelIndex++;
        gameId++;
        game = _build(levelIndex);
      });

  void _menu() => Navigator.of(context).pop();

  void _sendPointer(Offset local) =>
      game.onPointer(Vector2(local.dx, local.dy));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: K.bg,
      body: GestureDetector(
        onPanDown: (d) => _sendPointer(d.localPosition),
        onPanStart: (d) => _sendPointer(d.localPosition),
        onPanUpdate: (d) => _sendPointer(d.localPosition),
        child: GameWidget<DoketeGame>(
          key: ValueKey(gameId),
          game: game,
          initialActiveOverlays: const ['hud'],
          overlayBuilderMap: {
            'hud': (ctx, g) => _Hud(game: g, level: levelIndex),
            'result': (ctx, g) => _Result(
                  game: g,
                  level: levelIndex,
                  onRetry: _retry,
                  onNext: _next,
                  onMenu: _menu,
                ),
          },
        ),
      ),
    );
  }
}

/// プレイ中の最小HUD：残り秒数（中央上）とレベル（左上）。
class _Hud extends StatelessWidget {
  final DoketeGame game;
  final int level;
  const _Hud({required this.game, required this.level});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Positioned(
            top: 12,
            left: 16,
            child: Text(
              'Lv $level',
              style: const TextStyle(
                color: K.textSub,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ValueListenableBuilder<double>(
                valueListenable: game.remaining,
                builder: (_, v, __) {
                  final sec = v.ceil();
                  return Column(
                    children: [
                      Text(
                        '$sec',
                        style: TextStyle(
                          color: sec <= 5 ? K.fail : K.textDark,
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          height: 1.0,
                        ),
                      ),
                      const Text(
                        'たえろ',
                        style: TextStyle(color: K.textSub, fontSize: 12),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// クリア／失敗のリザルト。
class _Result extends StatelessWidget {
  final DoketeGame game;
  final int level;
  final VoidCallback onRetry;
  final VoidCallback onNext;
  final VoidCallback onMenu;

  const _Result({
    required this.game,
    required this.level,
    required this.onRetry,
    required this.onNext,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    final clear = game.status.value == GameStatus.clear;
    return Container(
      color: Colors.black.withOpacity(0.35),
      alignment: Alignment.center,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              clear ? 'クリア！' : 'つかまった…',
              style: TextStyle(
                color: clear ? K.clear : K.fail,
                fontSize: 30,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              clear ? 'Lv $level をたえきった' : 'Lv $level・もう一回いこう',
              style: const TextStyle(color: K.textSub, fontSize: 14),
            ),
            const SizedBox(height: 24),
            if (clear)
              _Btn(label: 'つぎへ', filled: true, onTap: onNext),
            if (clear) const SizedBox(height: 10),
            _Btn(
              label: 'もう一回',
              filled: !clear,
              onTap: onRetry,
            ),
            const SizedBox(height: 10),
            _Btn(label: 'メニュー', filled: false, onTap: onMenu),
          ],
        ),
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;
  const _Btn({required this.label, required this.filled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: filled ? K.player : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: filled
              ? BorderSide.none
              : const BorderSide(color: K.textSub, width: 1.4),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: filled ? Colors.white : K.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
