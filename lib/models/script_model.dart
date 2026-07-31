/// Modelo de datos de un guion (script) de teleprompter.
class ScriptModel {
  final String id;
  String title;
  String text;
  final int createdAt;
  int updatedAt;

  ScriptModel({
    required this.id,
    required this.title,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'text': text,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory ScriptModel.fromMap(Map<String, dynamic> map) {
    return ScriptModel(
      id: map['id'] as String,
      title: map['title'] as String,
      text: map['text'] as String,
      createdAt: map['createdAt'] as int,
      updatedAt: map['updatedAt'] as int,
    );
  }

  /// Cuenta de palabras del guion.
  int get wordCount {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).length;
  }

  /// Tiempo estimado de lectura en segundos (140 palabras/minuto).
  int get estimatedSeconds {
    return ((wordCount / 140) * 60).round();
  }
}

/// Modelo de datos de un video grabado.
class VideoModel {
  final String id;
  final String scriptId;
  String name;
  final String filePath;
  final int durationSeconds;
  final int createdAt;

  VideoModel({
    required this.id,
    required this.scriptId,
    required this.name,
    required this.filePath,
    required this.durationSeconds,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'scriptId': scriptId,
      'name': name,
      'filePath': filePath,
      'durationSeconds': durationSeconds,
      'createdAt': createdAt,
    };
  }

  factory VideoModel.fromMap(Map<String, dynamic> map) {
    return VideoModel(
      id: map['id'] as String,
      scriptId: map['scriptId'] as String,
      name: map['name'] as String,
      filePath: map['filePath'] as String,
      durationSeconds: map['durationSeconds'] as int,
      createdAt: map['createdAt'] as int,
    );
  }
}
