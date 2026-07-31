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
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: ContribiaColors.rojoRec)),
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
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/contribia_logo.png', width: 32, height: 32),
            const SizedBox(width: 10),
            const Text('Contribia Teleprompter'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.video_library_outlined),
            tooltip: 'Mis videos',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const VideoLibraryScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Configuración',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SettingsScreen(onThemeChanged: widget.onThemeChanged)),
              );
              setState(() {});
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewScript,
        backgroundColor: ContribiaColors.azulOscuro,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Guion'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _scripts.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadScripts,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                    itemCount: _scripts.length,
                    itemBuilder: (ctx, i) => _buildScriptCard(_scripts[i]),
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('📝', style: TextStyle(fontSize: 44)),
            SizedBox(height: 12),
            Text(
              'Aún no tienes guiones.\nCrea tu primer guion para empezar a grabar.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScriptCard(ScriptModel script) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              script.title.isEmpty ? 'Sin título' : script.title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 14,
              children: [
                Text('📅 ${_formatDate(script.updatedAt)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text('⏱ ${_formatDuration(script.estimatedSeconds)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text('🔤 ${script.wordCount} palabras', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _editScript(script),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Editar'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _recordScript(script),
                    icon: const Icon(Icons.videocam_outlined, size: 18),
                    label: const Text('Grabar'),
                  ),
                ),
                IconButton(
                  onPressed: () => _deleteScript(script),
                  icon: const Icon(Icons.delete_outline, color: ContribiaColors.rojoRec),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
