import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../config/levels.dart';
import '../data/progress.dart';
import 'game_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int clearedMax = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final c = await Progress.clearedMax();
    if (mounted) setState(() => clearedMax = c);
  }

  void _open(int lv) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => GameScreen(levelIndex: lv)))
        .then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: K.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'すみません、\nすみません',
                style: TextStyle(
                  color: K.textDark,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '人にぶつからず、たえるだけ。',
                style: TextStyle(color: K.textSub, fontSize: 14),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.builder(
                  itemCount: maxLevel,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.92,
                  ),
                  itemBuilder: (_, i) {
                    final lv = i + 1;
                    final cleared = lv <= clearedMax;
                    return _LevelTile(
                      level: lv,
                      seconds: getLevel(lv).surviveSeconds.toInt(),
                      cleared: cleared,
                      onTap: () => _open(lv),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  final int level;
  final int seconds;
  final bool cleared;
  final VoidCallback onTap;

  const _LevelTile({
    required this.level,
    required this.seconds,
    required this.cleared,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: cleared ? K.clear : const Color(0xFFE3E6EC),
              width: cleared ? 1.6 : 1,
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$level',
                      style: const TextStyle(
                        color: K.textDark,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${seconds}s',
                      style: const TextStyle(color: K.textSub, fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (cleared)
                const Positioned(
                  top: 6,
                  right: 6,
                  child: Icon(Icons.check_circle, color: K.clear, size: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
