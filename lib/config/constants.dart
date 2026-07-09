import 'package:flutter/material.dart';

/// ゲーム全体の基準値（速度・大きさ・色）。
/// バランス調整は基本ここと levels.dart だけ触れば済むようにしている。
class K {
  // --- サイズ（px） ---
  static const double playerRadius = 16;
  static const double npcRadius = 14;

  // --- 速度（px/秒） ---
  static const double playerFollowSpeed = 460; // 指への追従。速いほどキビキビ
  static const double fingerOffsetY = 48; // キャラは指の少し上に出す（指で隠さない）

  static const double normalSpeed = 58;
  static const double phoneSpeed = 40;
  static const double stopSpeed = 54;
  static const double uturnSpeed = 58;

  // --- 色 ---
  static const Color bg = Color(0xFFF4F5F7);
  static const Color player = Color(0xFFFF2D6B);
  static const Color playerRing = Color(0xFFB4003F);
  static const Color textDark = Color(0xFF20242C);
  static const Color textSub = Color(0xFF8A94A6);
  static const Color tell = Color(0xFFFFC400); // 予備動作リングの色
  static const Color clear = Color(0xFF2FB35E);
  static const Color fail = Color(0xFFE8503B);
}
