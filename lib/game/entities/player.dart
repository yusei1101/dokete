import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../config/constants.dart';

/// プレイヤー。指の位置（少し上）へキビキビ追従するだけ。
class Player extends Component {
  final Vector2 pos;
  final Vector2 arena;
  Vector2 target;
  final double radius = K.playerRadius;

  Player({required this.pos, required this.arena}) : target = pos.clone();

  void moveTo(Vector2 t) => target = t;

  @override
  void update(double dt) {
    final d = target - pos;
    final step = K.playerFollowSpeed * dt;
    if (d.length <= step) {
      pos.setFrom(target);
    } else {
      pos.add(d.normalized() * step);
    }
    pos.x = pos.x.clamp(radius, arena.x - radius);
    pos.y = pos.y.clamp(radius, arena.y - radius);
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(pos.x, pos.y);
    canvas.drawCircle(center, radius + 2, Paint()..color = K.playerRing);
    canvas.drawCircle(center, radius, Paint()..color = K.player);
  }
}
