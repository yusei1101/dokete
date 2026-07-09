/// レベル設計データ。数字を書き換えるだけで難易度を調整できる。
/// ここにはゲームロジックを書かない（ただの表）。
class LevelConfig {
  final int level;
  final double surviveSeconds; // 耐久時間
  final double tellSeconds; // 予備動作の長さ（短いほど難しい）
  final int normal; // 一般人
  final int phone; // スマホ歩き
  final int stop; // 急停止マン
  final int uturn; // Uターンマン
  final int talk; // 立ち話

  const LevelConfig(
    this.level,
    this.surviveSeconds,
    this.tellSeconds,
    this.normal,
    this.phone,
    this.stop,
    this.uturn,
    this.talk,
  );

  int get total => normal + phone + stop + uturn + talk;
}

/// 手作りのLv1〜12。ここが「もう一回」の感触を決める。
const List<LevelConfig> levelTable = <LevelConfig>[
  //          Lv 耐久 予備  一般 スマホ 停止 U 立話
  LevelConfig(1, 10, 0.50, 8, 0, 0, 0, 0),
  LevelConfig(2, 12, 0.50, 7, 0, 0, 0, 3),
  LevelConfig(3, 15, 0.50, 6, 3, 0, 0, 3),
  LevelConfig(4, 15, 0.50, 6, 4, 2, 0, 2),
  LevelConfig(5, 18, 0.50, 5, 4, 4, 0, 3),
  LevelConfig(6, 20, 0.50, 4, 4, 4, 3, 3),
  LevelConfig(7, 20, 0.45, 4, 5, 5, 4, 4),
  LevelConfig(8, 22, 0.45, 4, 6, 6, 5, 5),
  LevelConfig(9, 25, 0.40, 4, 7, 7, 6, 6),
  LevelConfig(10, 25, 0.40, 4, 8, 9, 7, 8),
  LevelConfig(11, 28, 0.35, 4, 10, 10, 9, 9),
  LevelConfig(12, 30, 0.30, 5, 12, 12, 11, 10),
];

/// メニューに並べるレベル数。表を超えた分は式で自動生成する。
const int maxLevel = 30;

/// Lv13以降を式で生成（無限に難しくなる）。
LevelConfig generateLevel(int lv) {
  final surv = (30 + (lv - 12) * 2).clamp(30, 45).toDouble();
  final weird = 45 + (lv - 12) * 6; // 一般人5を除いた変人総数の目安
  return LevelConfig(
    lv,
    surv,
    0.30,
    5,
    weird * 3 ~/ 11, // スマホ
    weird * 3 ~/ 11, // 急停止
    weird * 3 ~/ 11, // Uターン
    weird * 2 ~/ 11, // 立ち話
  );
}

/// レベル番号（1始まり）から設定を取得。
LevelConfig getLevel(int lv) {
  if (lv <= levelTable.length) return levelTable[lv - 1];
  return generateLevel(lv);
}
