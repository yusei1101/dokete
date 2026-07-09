# すみませんすみません（dokete）

人にぶつからず、制限時間だけ耐えるスマホゲーム。Flutter + Flame 製。
NPCの動きは全部ただの if 文ルール（AI・ML・サーバーは一切不要／完全オフライン）。

## いま入っているもの
- `lib/` … ゲームのソースコード一式（本体）
- `pubspec.yaml` … 依存関係（flame, shared_preferences）

※ `android/` `ios/` などの各OSフォルダはまだありません。Flutterを入れてから下の手順で生成します。

## 動かす手順

### 1. Flutter を入れる
https://docs.flutter.dev/get-started/install/windows
インストール後、`flutter doctor` が通ることを確認。

### 2. 各OSフォルダを生成（このフォルダの中で実行）
既存の `lib/` と `pubspec.yaml` はそのままに、android/ios だけ追加されます。

```
flutter create --platforms=android,ios .
```

### 3. 依存を取得
```
flutter pub get
```

### 4. 実行
実機かエミュレータを繋いで:
```
flutter run
```

PCで手早く見たいだけなら Chrome でも動きます（縦画面前提のUIですが確認用に）:
```
flutter config --enable-web
flutter create --platforms=web .
flutter run -d chrome
```

## 遊び方
- メニューでレベルを選ぶ
- 画面を指でなぞってキャラ（ピンク）を動かす
- 変な人にぶつからず、上の秒数を耐えきればクリア
- 黄色いリング = その人が「変な動きをする直前」の合図

## 難易度の調整場所
- `lib/config/levels.dart` … 各レベルの秒数・人数・変人の内訳（数字を書き換えるだけ）
- `lib/config/constants.dart` … 速度・当たり判定の大きさなどの基準値

## 変人の種類を増やすには
1. `lib/game/entities/npc_type.dart` の enum に種類を追加（色・速度も）
2. `lib/game/entities/npc.dart` の `update()` の switch に動きを1つ追加
3. `lib/config/levels.dart` に人数の列を足す

## ディレクトリ
```
lib/
├── main.dart
├── config/
│   ├── constants.dart   # 速度・大きさ・色
│   └── levels.dart      # レベル表
├── data/
│   └── progress.dart    # クリア進捗の保存
├── game/
│   ├── dokete_game.dart # ゲーム本体（湧き・衝突・タイマー）
│   └── entities/
│       ├── npc_type.dart
│       ├── npc.dart     # NPCの動き（ここに変人を足す）
│       └── player.dart
└── screens/
    ├── menu_screen.dart
    └── game_screen.dart # HUD・リザルトもここ
```
