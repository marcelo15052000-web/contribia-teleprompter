import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/settings_service.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SettingsService.instance.load();
  runApp(const ContribiaApp());
}

class ContribiaApp extends StatefulWidget {
  const ContribiaApp({super.key});

  @override
  State<ContribiaApp> createState() => _ContribiaAppState();
}

class _ContribiaAppState extends State<ContribiaApp> {
  void _refreshTheme() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contribia Teleprompter',
      debugShowCheckedModeBanner: false,
      theme: buildContribiaTheme(dark: SettingsService.instance.darkMode),
      home: HomeScreen(onThemeChanged: _refreshTheme),
    );
  }
}
