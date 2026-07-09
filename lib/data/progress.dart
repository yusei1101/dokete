import 'package:shared_preferences/shared_preferences.dart';

/// クリア進捗のローカル保存（サーバー不要）。保存するのは「どこまでクリアしたか」だけ。
class Progress {
  static const _key = 'cleared_max';

  static Future<int> clearedMax() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_key) ?? 0;
  }

  static Future<void> recordClear(int level) async {
    final p = await SharedPreferences.getInstance();
    final cur = p.getInt(_key) ?? 0;
    if (level > cur) await p.setInt(_key, level);
  }
}
