import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config/constants.dart';
import 'screens/menu_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const DoketeApp());
}

class DoketeApp extends StatelessWidget {
  const DoketeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'すみませんすみません',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: K.bg,
        useMaterial3: true,
      ),
      home: const MenuScreen(),
    );
  }
}
