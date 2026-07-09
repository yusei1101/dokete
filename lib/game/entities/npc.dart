import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../config/constants.dart';
import 'npc_type.dart';

/// 1体のNPC。タイプごとの動きは update() 内の switch で分岐するだけ。
/// 新しい変人を足したいときは NpcType に追加して、ここに case を1つ書けばよい。
class Npc extends Component {
  final NpcType type;
  final Vector2 pos;
  final Vector2 arena;
  final double tellDuration;
  final Random rng;

  late Vector2 heading; // まっすぐ歩く人の向き（単位ベクトル）
  late Vector2 target; // ふらふら歩く人の目的地
  final double speed;
  final double radius = K.npcRadius;

  // 急停止 / Uターン のタイミング管理
  double actionTimer = 0;
  bool stopped = false;
  double stoppedTimer = 0;

  Npc({
    required this.type,
    required this.pos,
    required this.arena,
    required this.tellDuration,
    required this.rng,
  }) : speed = type.speed {
    final ang = rng.nextDouble() * 2 * pi;
    heading = Vector2(cos(ang), sin(ang));
    target = _randomPoint();
    actionTimer = 2 + rng.nextDouble() * 3;
  }

  Vector2 _randomPoint() => Vector2(
        radius + rng.nextDouble() * (arena.x - 2 * radius),
        radius + rng.nextDouble() * (arena.y - 2 * radius),
      );

  /// 変な行動の直前かどうか（予備動作リングを出す判定）。
  bool get isTelling {
    if (type == NpcType.stop) return !stopped && actionTimer <= tellDuration;
    if (type == NpcType.uturn) return actionTimer <= tellDuration;
    return false;
  }

  @override
  void update(double dt) {
    switch (type) {
      case NpcType.normal:
        _wander(dt);
        break;
      case NpcType.phone:
        _straight(dt); // 下向き直進、周りを見ない
        break;
      case NpcType.stop:
        _sudden(dt); // たまに急に止まる
        break;
      case NpcType.uturn:
        _uturn(dt); // たまに急反転
        break;
      case NpcType.talk:
        break; // 立ち話：静止した障害物
    }
    _clamp();
  }

  // 目的地へ歩き、着いたら次の目的地へ
  void _wander(double dt) {
    final d = target - pos;
    if (d.length < 8) {
      target = _randomPoint();
    } else {
      pos.add(d.normalized() * speed * dt);
    }
  }

  // まっすぐ進み、壁で跳ね返る
  void _straight(double dt) {
    pos.add(heading * speed * dt);
    _bounce();
  }

  // 急停止：歩く → ビクッ(予備動作) → 数秒止まる → 再び歩く
  void _sudden(double dt) {
    if (stopped) {
      stoppedTimer -= dt;
      if (stoppedTimer <= 0) {
        stopped = false;
        actionTimer = 2.5 + rng.nextDouble() * 2.5;
      }
    } else {
      actionTimer -= dt;
      if (actionTimer <= 0) {
        stopped = true;
        stoppedTimer = 1.0 + rng.nextDouble();
      } else {
        _wander(dt);
      }
    }
  }

  // Uターン：まっすぐ進み、たまに向きを180度反転
  void _uturn(double dt) {
    actionTimer -= dt;
    if (actionTimer <= 0) {
      heading.negate(); // 向きを180度反転（in-place）
      actionTimer = 2 + rng.nextDouble() * 2.5;
    }
    pos.add(heading * speed * dt);
    _bounce();
  }

  void _bounce() {
    if (pos.x < radius) {
      pos.x = radius;
      heading.x = heading.x.abs();
    } else if (pos.x > arena.x - radius) {
      pos.x = arena.x - radius;
      heading.x = -heading.x.abs();
    }
    if (pos.y < radius) {
      pos.y = radius;
      heading.y = heading.y.abs();
    } else if (pos.y > arena.y - radius) {
      pos.y = arena.y - radius;
      heading.y = -heading.y.abs();
    }
  }

  void _clamp() {
    pos.x = pos.x.clamp(radius, arena.x - radius);
    pos.y = pos.y.clamp(radius, arena.y - radius);
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(pos.x, pos.y);

    // 予備動作リング（理不尽死を防ぐ核）
    if (isTelling) {
      final ring = Paint()
        ..color = K.tell
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(center, radius + 5, ring);
    }

    canvas.drawCircle(center, radius, Paint()..color = type.color);

    // スマホ歩きは画面の光を表現
    if (type == NpcType.phone) {
      canvas.drawCircle(
        center + const Offset(0, 3),
        3,
        Paint()..color = const Color(0xFFFFFFFF),
      );
    }
  }
}
