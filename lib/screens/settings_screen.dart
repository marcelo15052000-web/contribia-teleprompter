import 'package:flutter/material.dart';

import '../services/settings_service.dart';
import '../theme.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onThemeChanged;
  const SettingsScreen({super.key, required this.onThemeChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final settings = SettingsService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('⚙️ Configuración')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle('Apariencia'),
          _switchTile('Modo oscuro', settings.darkMode, (v) {
            setState(() => settings.setDarkMode(v));
            widget.onThemeChanged();
          }),

          _sectionTitle('Teleprompter por defecto'),
          Text('Velocidad: ${settings.speedLabel}', style: const TextStyle(fontWeight: FontWeight.w600)),
          Slider(
            value: settings.speed.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            activeColor: ContribiaColors.celeste,
            label: settings.speedLabel,
            onChanged: (v) => setState(() => settings.setSpeed(v.toInt())),
          ),
          _switchTile('Mantener pantalla encendida', settings.keepScreenOn, (v) {
            setState(() => settings.setKeepScreenOn(v));
          }),

          _sectionTitle('Resaltado inteligente'),
          _switchTile('Números', settings.highlightNumbers, (v) {
            setState(() => settings.setHighlight('numbers', v));
          }),
          _switchTile('Leyes y artículos', settings.highlightLaws, (v) {
            setState(() => settings.setHighlight('laws', v));
          }),
          _switchTile('Fechas', settings.highlightDates, (v) {
            setState(() => settings.setHighlight('dates', v));
          }),
          _switchTile('Valores monetarios', settings.highlightMoney, (v) {
            setState(() => settings.setHighlight('money', v));
          }),

          _sectionTitle('Acerca de'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Text(
              'Contribia Teleprompter v1.0\n'
              'App nativa Android · Funciona sin conexión\n'
              'Asesoría Contable y Tributaria — Ecuador',
              style: TextStyle(color: Colors.grey, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1, color: Colors.grey),
      ),
    );
  }

  Widget _switchTile(String label, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      value: value,
      activeColor: ContribiaColors.celeste,
      onChanged: onChanged,
    );
  }
}
