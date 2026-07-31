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
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _sectionCard(
            title: 'Apariencia',
            icon: Icons.palette_rounded,
            color: ContribiaColors.celeste,
            children: [
              _switchTile(Icons.dark_mode_rounded, 'Modo oscuro', settings.darkMode, (v) {
                setState(() => settings.setDarkMode(v));
                widget.onThemeChanged();
              }),
            ],
          ),
          const SizedBox(height: 16),
          _sectionCard(
            title: 'Teleprompter por defecto',
            icon: Icons.speed_rounded,
            color: ContribiaColors.verde,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Velocidad', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text(settings.speedLabel, style: const TextStyle(color: ContribiaColors.celeste, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              Slider(
                value: settings.speed.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                label: settings.speedLabel,
                onChanged: (v) => setState(() => settings.setSpeed(v.toInt())),
              ),
              const Divider(height: 8),
              _switchTile(Icons.stay_current_portrait_rounded, 'Mantener pantalla encendida', settings.keepScreenOn, (v) {
                setState(() => settings.setKeepScreenOn(v));
              }),
            ],
          ),
          const SizedBox(height: 16),
          _sectionCard(
            title: 'Resaltado inteligente',
            icon: Icons.auto_awesome_rounded,
            color: ContribiaColors.amarillo,
            children: [
              _switchTile(Icons.pin_rounded, 'Números', settings.highlightNumbers, (v) {
                setState(() => settings.setHighlight('numbers', v));
              }),
              _switchTile(Icons.gavel_rounded, 'Leyes y artículos', settings.highlightLaws, (v) {
                setState(() => settings.setHighlight('laws', v));
              }),
              _switchTile(Icons.event_rounded, 'Fechas', settings.highlightDates, (v) {
                setState(() => settings.setHighlight('dates', v));
              }),
              _switchTile(Icons.attach_money_rounded, 'Valores monetarios', settings.highlightMoney, (v) {
                setState(() => settings.setHighlight('money', v));
              }),
            ],
          ),
          const SizedBox(height: 16),
          _sectionCard(
            title: 'Acerca de',
            icon: Icons.info_outline_rounded,
            color: ContribiaColors.azulOscuro,
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'Contribia Teleprompter v1.0\n'
                  'App nativa Android · Funciona sin conexión\n'
                  'Asesoría Contable y Tributaria — Ecuador',
                  style: TextStyle(color: Colors.grey, height: 1.6, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                BrandIconBadge(icon: icon, color: color, size: 34),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _switchTile(IconData icon, String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        secondary: Icon(icon, size: 20, color: Colors.grey),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5)),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
