import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../models/script_model.dart';
import '../services/database_service.dart';
import '../services/highlight_service.dart';
import '../services/settings_service.dart';
import '../theme.dart';

class RecordScreen extends StatefulWidget {
  final ScriptModel script;
  const RecordScreen({super.key, required this.script});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  int _cameraIndex = 0;

  final ScrollController _scrollController = ScrollController();
  Timer? _scrollTimer;
  bool _isScrolling = false;
  double _scrollSpeed = SettingsService.instance.pxPerTick;

  bool _isRecording = false;
  int _recSeconds = 0;
  Timer? _recTimer;

  bool _mirror = SettingsService.instance.mirrorMode;
  double _fontSize = SettingsService.instance.fontSize;

  @override
  void initState() {
    super.initState();
    _initCamera();
    if (SettingsService.instance.keepScreenOn) {
      WakelockPlus.enable();
    }
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isEmpty) return;
    // Prioriza cámara frontal para grabación tipo "vlog"
    _cameraIndex = _cameras.indexWhere((c) => c.lensDirection == CameraLensDirection.front);
    if (_cameraIndex < 0) _cameraIndex = 0;
    await _startCamera(_cameraIndex);
  }

  Future<void> _startCamera(int index) async {
    await _cameraController?.dispose();
    final controller = CameraController(
      _cameras[index],
      ResolutionPreset.high,
      enableAudio: true,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    _cameraController = controller;
    try {
      await controller.initialize();
      // Bitrate más alto para acercarse a la calidad de la app nativa de cámara
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Error al iniciar la cámara: $e');
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;
    await _startCamera(_cameraIndex);
  }

  void _toggleScroll() {
    if (_isScrolling) {
      _scrollTimer?.cancel();
      setState(() => _isScrolling = false);
    } else {
      setState(() => _isScrolling = true);
      _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
        if (!_scrollController.hasClients) return;
        final next = _scrollController.offset + _scrollSpeed;
        final max = _scrollController.position.maxScrollExtent;
        if (next >= max) {
          _scrollController.jumpTo(max);
          _scrollTimer?.cancel();
          setState(() => _isScrolling = false);
        } else {
          _scrollController.jumpTo(next);
        }
      });
    }
  }

  void _stopScroll() {
    _scrollTimer?.cancel();
    setState(() => _isScrolling = false);
    _scrollController.jumpTo(0);
  }

  Future<void> _toggleRecording() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    if (!_isRecording) {
      try {
        await _cameraController!.startVideoRecording();
        setState(() {
          _isRecording = true;
          _recSeconds = 0;
        });
        _recTimer = Timer.periodic(const Duration(seconds: 1), (_) {
          setState(() => _recSeconds++);
        });
        // Inicia automáticamente el desplazamiento del teleprompter
        if (!_isScrolling) _toggleScroll();
      } catch (e) {
        debugPrint('Error al iniciar grabación: $e');
      }
    } else {
      _recTimer?.cancel();
      try {
        final XFile file = await _cameraController!.stopVideoRecording();
        setState(() => _isRecording = false);
        await _saveRecording(file);
      } catch (e) {
        debugPrint('Error al detener grabación: $e');
      }
    }
  }

  Future<void> _saveRecording(XFile file) async {
    final dir = await getApplicationDocumentsDirectory();
    final videosDir = Directory('${dir.path}/videos');
    if (!await videosDir.exists()) await videosDir.create(recursive: true);

    final id = const Uuid().v4();
    final ext = file.path.split('.').last;
    final destPath = '${videosDir.path}/$id.$ext';
    await File(file.path).copy(destPath);

    await DatabaseService.instance.saveVideo(
      VideoModel(
        id: id,
        scriptId: widget.script.id,
        name: widget.script.title.isEmpty ? 'Video Contribia' : widget.script.title,
        filePath: destPath,
        durationSeconds: _recSeconds,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Video guardado en Contribia 🎬 · Usa "Compartir" en Mis Videos para enviarlo a tu galería'),
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _recTimer?.cancel();
    _cameraController?.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Cámara en pantalla completa
          if (_cameraController != null && _cameraController!.value.isInitialized)
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _cameraController!.value.previewSize?.height ?? 1,
                  height: _cameraController!.value.previewSize?.width ?? 1,
                  child: CameraPreview(_cameraController!),
                ),
              ),
            )
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),

          // Línea central guía
          Positioned(
            left: 0,
            right: 0,
            top: MediaQuery.of(context).size.height / 2,
            child: Container(height: 1.5, color: ContribiaColors.celeste.withOpacity(0.35)),
          ),

          // Texto del teleprompter (con máscara de desvanecido arriba/abajo)
          Positioned.fill(
            child: ShaderMask(
              shaderCallback: (rect) => const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black, Colors.black, Colors.transparent],
                stops: [0.0, 0.12, 0.88, 1.0],
              ).createShader(rect),
              blendMode: BlendMode.dstIn,
              child: Container(
                color: Colors.black.withOpacity(0.35),
                child: Transform(
                  alignment: Alignment.center,
                  transform: _mirror ? (Matrix4.identity()..scale(-1.0, 1.0)) : Matrix4.identity(),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * 0.42,
                      horizontal: 24,
                    ),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: HighlightService.buildSpans(
                          widget.script.text,
                          fontSize: _fontSize,
                          baseColor: Colors.white,
                          options: HighlightOptions(
                            numbers: SettingsService.instance.highlightNumbers,
                            laws: SettingsService.instance.highlightLaws,
                            dates: SettingsService.instance.highlightDates,
                            money: SettingsService.instance.highlightMoney,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Barra superior
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, left: 12, right: 12, bottom: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.55), Colors.transparent],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: [
                        if (_isRecording)
                          const Icon(Icons.circle, color: ContribiaColors.rojoRec, size: 10),
                        if (_isRecording) const SizedBox(width: 6),
                        Text(
                          _formatDuration(_recSeconds),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: _openQuickSettings,
                  ),
                ],
              ),
            ),
          ),

          // Barra inferior de controles
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: MediaQuery.of(context).padding.bottom + 20,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.65), Colors.transparent],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.slow_motion_video, color: Colors.white70, size: 18),
                      Expanded(
                        child: Slider(
                          value: SettingsService.instance.speed.toDouble(),
                          min: 1,
                          max: 5,
                          divisions: 4,
                          activeColor: ContribiaColors.celeste,
                          onChanged: (v) {
                            SettingsService.instance.setSpeed(v.toInt());
                            setState(() => _scrollSpeed = SettingsService.instance.pxPerTick);
                          },
                        ),
                      ),
                      const Icon(Icons.fast_forward, color: Colors.white70, size: 18),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _roundButton(Icons.cameraswitch, _switchCamera),
                      _roundButton(_isScrolling ? Icons.pause : Icons.play_arrow, _toggleScroll),
                      _recordButton(),
                      _roundButton(Icons.flip, () {
                        setState(() => _mirror = !_mirror);
                        SettingsService.instance.setMirrorMode(_mirror);
                      }),
                      _roundButton(Icons.stop, _stopScroll),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  Widget _recordButton() {
    return InkWell(
      onTap: _toggleRecording,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 74,
        height: 74,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
        ),
        padding: const EdgeInsets.all(6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: ContribiaColors.rojoRec,
            borderRadius: BorderRadius.circular(_isRecording ? 8 : 40),
          ),
        ),
      ),
    );
  }

  void _openQuickSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF131C31),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Tamaño de letra', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                Slider(
                  value: _fontSize,
                  min: 24,
                  max: 72,
                  activeColor: ContribiaColors.celeste,
                  onChanged: (v) {
                    setSheetState(() {});
                    setState(() => _fontSize = v);
                    SettingsService.instance.setFontSize(v);
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Mantener pantalla encendida', style: TextStyle(color: Colors.white)),
                    Switch(
                      value: SettingsService.instance.keepScreenOn,
                      activeColor: ContribiaColors.celeste,
                      onChanged: (v) {
                        setSheetState(() {});
                        SettingsService.instance.setKeepScreenOn(v);
                        v ? WakelockPlus.enable() : WakelockPlus.disable();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
