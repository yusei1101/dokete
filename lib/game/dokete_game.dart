import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../config/levels.dart';
import 'entities/npc.dart';
import 'entities/npc_type.dart';
import 'entities/player.dart';

enum GameStatus { playing, clear, fail }

/// ゲーム本体。薄く保つ：スポーン・衝突・タイマーだけ持つ。
class DoketeGame extends FlameGame {
  DoketeGame(this.config);

  final LevelConfig config;
  final Random _rng = Random();

  late Player player;
  final List<Npc> npcs = [];

  // UI側（Flutter）が監視する状態
  final ValueNotifier<double> remaining = ValueNotifier(0);
  final ValueNotifier<GameStatus> status = ValueNotifier(GameStatus.playing);

  double _startGrace = 1.2; // 開始直後は当たらない（理不尽死防止）
  bool _spawned = false;

  @override
  Color backgroundColor() => K.bg;

  @override
  Future<void> onLoad() async {
    remaining.value = config.surviveSeconds;
    _spawn();
  }

  void _spawn() {
    if (_spawned) return;
    _spawned = true;
    final arena = size.clone();

    void addNpcs(NpcType type, int count) {
      for (var i = 0; i < count; i++) {
        final npc = Npc(
          type: type,
          pos: _safeSpawn(arena),
          arena: arena,
          tellDuration: config.tellSeconds,
          rng: _rng,
        );
        npcs.add(npc);
        add(npc);
      }
    }

    // NPCを先に追加 → プレイヤーは最後（最前面に描く）
    addNpcs(NpcType.normal, config.normal);
    addNpcs(NpcType.phone, config.phone);
    addNpcs(NpcType.stop, config.stop);
    addNpcs(NpcType.uturn, config.uturn);
    _spawnTalkGroups(arena, config.talk);

    player = Player(pos: Vector2(arena.x / 2, arena.y * 0.7), arena: arena);
    add(player);
  }

  // プレイヤー開始位置から離れた安全な湧き位置を探す
  Vector2 _safeSpawn(Vector2 arena) {
    final start = Vector2(arena.x / 2, arena.y * 0.7);
    for (var i = 0; i < 30; i++) {
      final p = _randomInArena(arena);
      if ((p - start).length > 90) return p;
    }
    return _randomInArena(arena);
  }

  Vector2 _randomInArena(Vector2 arena) => Vector2(
        K.npcRadius + _rng.nextDouble() * (arena.x - 2 * K.npcRadius),
        K.npcRadius + _rng.nextDouble() * (arena.y - 2 * K.npcRadius),
      );

  // 立ち話は2〜3人のかたまりで配置
  void _spawnTalkGroups(Vector2 arena, int total) {
    var left = total;
    while (left > 0) {
      final groupSize = left >= 3 ? (2 + _rng.nextInt(2)) : left;
      final center = _safeSpawn(arena);
      for (var i = 0; i < groupSize; i++) {
        final ang = _rng.nextDouble() * 2 * pi;
        final off = Vector2(cos(ang), sin(ang)) * (K.npcRadius * 2.2);
        final p = center + off;
        final npc = Npc(
          type: NpcType.talk,
          pos: Vector2(
            p.x.clamp(K.npcRadius, arena.x - K.npcRadius),
            p.y.clamp(K.npcRadius, arena.y - K.npcRadius),
          ),
          arena: arena,
          tellDuration: config.tellSeconds,
          rng: _rng,
        );
        npcs.add(npc);
        add(npc);
      }
      left -= groupSize;
    }
  }

  // 指の入力（画面座標）を受け取る
  void onPointer(Vector2 p) {
    if (!_spawned || status.value != GameStatus.playing) return;
    player.moveTo(Vector2(p.x, p.y - K.fingerOffsetY));
  }

  @override
  void update(double dt) {
    if (status.value != GameStatus.playing) return; // 終了後は画面を止める
    super.update(dt);

    if (_startGrace > 0) {
      _startGrace -= dt;
    } else {
      final pr = player.radius;
      for (final npc in npcs) {
        if ((npc.pos - player.pos).length < pr + npc.radius - 2) {
          status.value = GameStatus.fail;
          overlays.add('result');
          return;
        }
      }
    }

    remaining.value -= dt;
    if (remaining.value <= 0) {
      remaining.value = 0;
      status.value = GameStatus.clear;
      overlays.add('result');
    }
  }
}
