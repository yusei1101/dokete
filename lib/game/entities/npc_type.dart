import 'package:flutter/material.dart';
import '../../config/constants.dart';

/// NPCの行動タイプ。中身は全部ただの if 文ルール（AI・MLは一切不要）。
enum NpcType { normal, phone, stop, uturn, talk }

extension NpcTypeX on NpcType {
  Color get color {
    switch (this) {
      case NpcType.normal:
        return const Color(0xFF8A94A6); // 灰青：安心枠
      case NpcType.phone:
        return const Color(0xFF2FB6C9); // 水色：スマホ歩き
      case NpcType.stop:
        return const Color(0xFFE8853B); // 橙：急停止
      case NpcType.uturn:
        return const Color(0xFF9B6DD6); // 紫：Uターン
      case NpcType.talk:
        return const Color(0xFF57B36B); // 緑：立ち話
    }
  }

  double get speed {
    switch (this) {
      case NpcType.normal:
        return K.normalSpeed;
      case NpcType.phone:
        return K.phoneSpeed;
      case NpcType.stop:
        return K.stopSpeed;
      case NpcType.uturn:
        return K.uturnSpeed;
      case NpcType.talk:
        return 0;
    }
  }
}
