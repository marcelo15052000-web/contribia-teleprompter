import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../models/script_model.dart';
import '../services/database_service.dart';
import '../theme.dart';

class VideoLibraryScreen extends StatefulWidget {
  const VideoLibraryScreen({super.key});

  @override
  State<VideoLibraryScreen> createState() => _VideoLibraryScreenState();
}

class _VideoLibraryScreenState extends State<VideoLibraryScreen> {
  List<VideoModel> _videos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final videos = await DatabaseService.instance.getAllVideos();
    setState(() {
      _videos = videos;
      _loading = false;
    });
  }

  Future<void> _rename(VideoModel video) async {
    final controller = TextEditingController(text: video.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Renombrar video'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, controller.text), child: const Text('Guardar')),
        ],
      ),
    );
    if (newName != null && newName.trim().isNotEmpty) {
      await DatabaseService.instance.renameVideo(video.id, newName.trim());
      _load();
    }
  }

  Future<void> _delete(VideoModel video) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar video'),
        content: const Text('¿Eliminar este video de Contribia? Si ya lo compartiste o guardaste en tu galería, esa copia no se verá afectada.'),
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
      await DatabaseService.instance.deleteVideo(video.id);
      _load();
    }
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🎬 Mis Videos')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _videos.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const BrandIconBadge(icon: Icons.video_library_rounded, size: 72, color: ContribiaColors.celeste),
                        const SizedBox(height: 20),
                        const Text('Todavía no has grabado videos', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text(
                          'Graba con el teleprompter y tus videos\naparecerán aquí.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _videos.length,
                  itemBuilder: (ctx, i) {
                    final video = _videos[i];
                    final exists = File(video.filePath).existsSync();
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const BrandIconBadge(icon: Icons.movie_rounded, color: ContribiaColors.celeste, size: 34),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(video.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.timer_outlined, size: 13, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(_formatDuration(video.durationSeconds),
                                    style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
                              ],
                            ),
                            if (!exists)
                              const Padding(
                                padding: EdgeInsets.only(top: 6),
                                child: Text('⚠️ Archivo no encontrado en este dispositivo',
                                    style: TextStyle(color: Colors.orange, fontSize: 12)),
                              ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () => _rename(video),
                                  icon: const Icon(Icons.edit_rounded, size: 16),
                                  label: const Text('Renombrar'),
                                ),
                                if (exists)
                                  OutlinedButton.icon(
                                    onPressed: () => Share.shareXFiles([XFile(video.filePath)], text: video.name),
                                    icon: const Icon(Icons.share_rounded, size: 16),
                                    label: const Text('Compartir'),
                                  ),
                                OutlinedButton.icon(
                                  onPressed: () => _delete(video),
                                  icon: const Icon(Icons.delete_outline_rounded, size: 16, color: ContribiaColors.rojoRec),
                                  label: const Text('Eliminar', style: TextStyle(color: ContribiaColors.rojoRec)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
