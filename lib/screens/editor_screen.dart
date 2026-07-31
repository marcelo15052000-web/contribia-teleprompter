import 'dart:async';
import 'package:flutter/material.dart';

import '../models/script_model.dart';
import '../services/ai_helper_service.dart';
import '../services/database_service.dart';
import '../theme.dart';
import 'record_screen.dart';

class EditorScreen extends StatefulWidget {
  final ScriptModel script;
  final bool isNew;

  const EditorScreen({super.key, required this.script, required this.isNew});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _textController;
  Timer? _autosaveTimer;
  String _status = 'Guardado ✓';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.script.title);
    _textController = TextEditingController(text: widget.script.text);
    _titleController.addListener(_scheduleAutosave);
    _textController.addListener(_scheduleAutosave);
  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _scheduleAutosave() {
    setState(() => _status = 'Guardando…');
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(const Duration(milliseconds: 900), _save);
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty && _textController.text.trim().isEmpty) {
      return;
    }
    widget.script.title = _titleController.text.trim().isEmpty ? 'Sin título' : _titleController.text.trim();
    widget.script.text = _textController.text;
    widget.script.updatedAt = DateTime.now().millisecondsSinceEpoch;
    await DatabaseService.instance.saveScript(widget.script);
    if (mounted) setState(() => _status = 'Guardado ✓');
  }

  void _insertAtCursor(String insertText) {
    final text = _textController.text;
    final selection = _textController.selection;
    final start = selection.start < 0 ? text.length : selection.start;
    final end = selection.end < 0 ? text.length : selection.end;
    final newText = text.replaceRange(start, end, insertText);
    _textController.text = newText;
    _textController.selection = TextSelection.collapsed(offset: start + insertText.length);
  }

  void _wrapSelection(String before, String after) {
    final text = _textController.text;
    final selection = _textController.selection;
    if (!selection.isValid || selection.isCollapsed) {
      _insertAtCursor('$before palabra$after');
      return;
    }
    final selected = text.substring(selection.start, selection.end);
    final newText = text.replaceRange(selection.start, selection.end, '$before$selected$after');
    _textController.text = newText;
  }

  int get _wordCount {
    final trimmed = _textController.text.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).length;
  }

  int get _estimatedSeconds => ((_wordCount / 140) * 60).round();

  void _applyAiAction(String action, {String tone = 'formal'}) {
    final improved = AiHelperService.improve(_textController.text, action, tone: tone);
    setState(() => _textController.text = improved);
    _scheduleAutosave();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Guion mejorado ✨')),
    );
  }

  void _openAiPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (ctx, scrollCtrl) => Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              controller: scrollCtrl,
              children: [
                const Text('✨ Mejorar Guion', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                const Text(
                  'Mejora local (sin conexión). Próximamente: mejora con IA en la nube.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _aiChip('✅ Corregir ortografía', () => _applyAiAction('ortografia')),
                    _aiChip('💬 Más natural', () => _applyAiAction('natural')),
                    _aiChip('👔 Más profesional', () => _applyAiAction('profesional')),
                    _aiChip('🎯 Más persuasivo', () => _applyAiAction('persuasivo')),
                    _aiChip('✂️ Más corto', () => _applyAiAction('corto')),
                    _aiChip('📝 Más largo', () => _applyAiAction('largo')),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Cambiar tono', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _aiChip('Formal', () => _applyAiAction('tono', tone: 'formal')),
                    _aiChip('Amigable', () => _applyAiAction('tono', tone: 'amigable')),
                    _aiChip('Didáctico', () => _applyAiAction('tono', tone: 'didactico')),
                    _aiChip('Vendedor', () => _applyAiAction('tono', tone: 'vendedor')),
                    _aiChip('YouTube', () => _applyAiAction('tono', tone: 'youtube')),
                    _aiChip('TikTok', () => _applyAiAction('tono', tone: 'tiktok')),
                    _aiChip('Instagram', () => _applyAiAction('tono', tone: 'instagram')),
                    _aiChip('Facebook', () => _applyAiAction('tono', tone: 'facebook')),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _aiChip(String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: ContribiaColors.azulOscuro.withOpacity(0.08),
    );
  }

  Future<void> _goToRecord() async {
    await _save();
    if (!mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => RecordScreen(script: widget.script)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await _save();
            if (mounted) Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.format_underline),
            tooltip: 'Resaltar palabra seleccionada',
            onPressed: () => _wrapSelection('*', '*'),
          ),
          IconButton(
            icon: const Icon(Icons.pause_circle_outline),
            tooltip: 'Insertar pausa',
            onPressed: () => _insertAtCursor(' [pausa] '),
          ),
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: ContribiaColors.celeste),
            tooltip: '✨ Mejorar Guion',
            onPressed: _openAiPanel,
          ),
          TextButton.icon(
            onPressed: _goToRecord,
            icon: const Icon(Icons.videocam_outlined),
            label: const Text('Grabar'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                controller: _titleController,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                decoration: const InputDecoration(
                  hintText: 'Título del guion',
                  border: InputBorder.none,
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _textController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: const TextStyle(fontSize: 17, height: 1.5),
                  decoration: const InputDecoration(
                    hintText: 'Escribe aquí tu guion…\n\nTip: usa *palabra* para marcar palabras '
                        'difíciles y [pausa] para insertar una pausa.',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$_wordCount palabras', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  Text('~${_estimatedSeconds ~/ 60}:${(_estimatedSeconds % 60).toString().padLeft(2, '0')} de lectura',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(_status, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
