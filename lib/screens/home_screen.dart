import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/script_model.dart';
import '../services/database_service.dart';
import '../theme.dart';
import 'editor_screen.dart';
import 'record_screen.dart';
import 'settings_screen.dart';
import 'video_library_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onThemeChanged;
  const HomeScreen({super.key, required this.onThemeChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ScriptModel> _scripts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadScripts();
  }

  Future<void> _loadScripts() async {
    setState(() => _loading = true);
    final scripts = await DatabaseService.instance.getAllScripts();
    setState(() {
      _scripts = scripts;
      _loading = false;
    });
  }

  Future<void> _createNewScript() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final script = ScriptModel(
      id: const Uuid().v4(),
      title: '',
      text: '',
      createdAt: now,
      updatedAt: now,
    );
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditorScreen(script: script, isNew: true)),
    );
    _loadScripts();
  }

  Future<void> _editScript(ScriptModel script) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditorScreen(script: script, isNew: false)),
    );
    _loadScripts();
  }

  Future<void> _recordScript(ScriptModel script) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RecordScreen(script: script)),
    );
  }

  Future<void> _deleteScript(ScriptModel script) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar guion'),
        content: const Text('¿Seguro que deseas eliminar este guion? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: ContribiaColors.rojoRec),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await DatabaseService.instance.deleteScript(script.id);
      _loadScripts();
    }
  }

  String _formatDate(int millis) {
    final d = DateTime.fromMillisecondsSinceEpoch(millis);
    const meses = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    return '${d.day} ${meses[d.month - 1]}';
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: Container(
                width: 36,
                height: 36,
                color: Colors.white,
                padding: const EdgeInsets.all(4),
                child: Image.asset('assets/images/contribia_logo.png'),
              ),
            ),
            const SizedBox(width: 12),
            const Text('Contribia'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.video_library_rounded),
            tooltip: 'Mis videos',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const VideoLibraryScreen()),
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            tooltip: 'Configuración',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SettingsScreen(onThemeChanged: widget.onThemeChanged)),
              );
              setState(() {});
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewScript,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nuevo Guion'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _scripts.isEmpty
              ? _buildEmptyState(context)
              : RefreshIndicator(
                  onRefresh: _loadScripts,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Tus guiones',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      ..._scripts.map((s) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildScriptCard(context, s, isDark),
                          )),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BrandIconBadge(icon: Icons.description_rounded, size: 72, color: ContribiaColors.celeste),
            const SizedBox(height: 20),
            Text('Aún no tienes guiones', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Crea tu primer guion para empezar a grabar\ncon el teleprompter de Contribia.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, height: 1.5),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _createNewScript,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Crear guion'),
              style: FilledButton.styleFrom(
                backgroundColor: ContribiaColors.azulOscuro,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScriptCard(BuildContext context, ScriptModel script, bool isDark) {
    return Card(
      child: InkWell(
        onTap: () => _editScript(script),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BrandIconBadge(icon: Icons.article_rounded, color: ContribiaColors.azulOscuro),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          script.title.isEmpty ? 'Sin título' : script.title,
                          style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 12,
                          runSpacing: 4,
                          children: [
                            _metaChip(context, Icons.calendar_today_rounded, _formatDate(script.updatedAt)),
                            _metaChip(context, Icons.timer_outlined, _formatDuration(script.estimatedSeconds)),
                            _metaChip(context, Icons.short_text_rounded, '${script.wordCount} palabras'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _deleteScript(script),
                    icon: const Icon(Icons.delete_outline_rounded, color: ContribiaColors.rojoRec, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _editScript(script),
                      icon: const Icon(Icons.edit_rounded, size: 17),
                      label: const Text('Editar'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _recordScript(script),
                      icon: const Icon(Icons.videocam_rounded, size: 18),
                      label: const Text('Grabar'),
                      style: FilledButton.styleFrom(
                        backgroundColor: ContribiaColors.azulOscuro,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metaChip(BuildContext context, IconData icon, String label) {
    final color = Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
