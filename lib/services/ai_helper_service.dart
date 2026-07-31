/// ai_helper_service.dart — "✨ Mejorar Guion"
///
/// NOTA: la app funciona sin conexión y sin backend propio, por lo que
/// no puede llamar a un modelo de IA en la nube sin exponer credenciales
/// en el cliente. Este servicio implementa heurísticas locales de mejora
/// de texto (ortografía básica, tono, longitud). Está aislado para que
/// sea fácil de reemplazar por una llamada real a un backend/IA a futuro.
class AiHelperService {
  static const Map<String, List<String>> _toneConnectors = {
    'formal': ['Cabe destacar que', 'Es importante señalar que', 'Asimismo,'],
    'amigable': ['Oye,', 'Fíjate que', 'Además,'],
    'didactico': ['Para entenderlo mejor,', 'En otras palabras,', 'Veamos un ejemplo:'],
    'vendedor': ['No dejes pasar esto:', 'Esto te interesa:', 'Aprovecha ahora:'],
    'youtube': ['Antes de continuar,', 'Como les comentaba,', 'Suscríbete para más contenido así.'],
    'tiktok': ['Mira esto:', 'No lo vas a creer:', 'Dato clave:'],
    'instagram': ['✨', 'Guarda este post:', 'Cuéntame en comentarios:'],
    'facebook': ['Comparte si te sirvió:', 'Cuéntanos tu opinión:', 'Etiqueta a alguien que necesite esto:'],
  };

  static final List<List<dynamic>> _commonFixes = [
    [RegExp(r'\bal rededor\b', caseSensitive: false), 'alrededor'],
    [RegExp(r'\basi mismo\b', caseSensitive: false), 'asimismo'],
    [RegExp(r'\bde el\b', caseSensitive: false), 'del'],
    [RegExp(r'\ba el\b', caseSensitive: false), 'al'],
    [RegExp(r' {2,}'), ' '],
    [RegExp(r' +([.,;:])'), r'$1'],
  ];

  static String fixSpelling(String text) {
    var result = text;
    for (final fix in _commonFixes) {
      result = result.replaceAll(fix[0] as RegExp, fix[1] as String);
    }
    return result.trim();
  }

  static String makeShorter(String text) {
    final sentences = text.split(RegExp(r'(?<=[.!?])\s+'));
    final keep = (sentences.length * 0.7).ceil().clamp(1, sentences.length);
    return sentences.take(keep).join(' ');
  }

  static String makeLonger(String text, String tone) {
    final connectors = _toneConnectors[tone] ?? _toneConnectors['formal']!;
    final sentences = text.split(RegExp(r'(?<=[.!?])\s+'));
    final expanded = <String>[];
    for (var i = 0; i < sentences.length; i++) {
      if (i > 0 && i % 2 == 0) {
        expanded.add('${connectors[i % connectors.length]} ${sentences[i]}');
      } else {
        expanded.add(sentences[i]);
      }
    }
    return expanded.join(' ');
  }

  static String applyTone(String text, String tone) {
    final connectors = _toneConnectors[tone];
    if (connectors == null) return text;
    final sentences = text.split(RegExp(r'(?<=[.!?])\s+'));
    if (sentences.isEmpty) return text;
    sentences[0] = '${connectors[0]} ${sentences[0]}';
    return sentences.join(' ');
  }

  static String makeMoreProfessional(String text) {
    return text
        .replaceAll(RegExp(r'\bmuy\s+', caseSensitive: false), 'considerablemente ')
        .replaceAll(RegExp(r'\bcosas\b', caseSensitive: false), 'aspectos')
        .replaceAll(RegExp(r'\bbueno\b', caseSensitive: false), 'adecuado')
        .replaceAll(RegExp(r'\bmalo\b', caseSensitive: false), 'inadecuado');
  }

  static String makeMorePersuasive(String text) {
    const closers = [
      '\n\nNo esperes más: contacta hoy mismo con Contribia.',
      '\n\nContribia está lista para ayudarte a cumplir con tus obligaciones tributarias.',
      '\n\nEsto es exactamente lo que tu negocio necesita hoy.',
    ];
    final closer = closers[DateTime.now().millisecond % closers.length];
    return text.trim() + closer;
  }

  static String makeMoreNatural(String text) {
    return text
        .replaceAll(RegExp(r'\butilizar\b', caseSensitive: false), 'usar')
        .replaceAll(RegExp(r'\badquirir\b', caseSensitive: false), 'conseguir')
        .replaceAll(RegExp(r'\bcon el fin de\b', caseSensitive: false), 'para')
        .replaceAll(RegExp(r'\bdebido a que\b', caseSensitive: false), 'porque');
  }

  /// Punto de entrada del Modo IA local.
  /// action: 'ortografia' | 'natural' | 'profesional' | 'persuasivo' | 'corto' | 'largo' | 'tono'
  static String improve(String text, String action, {String tone = 'formal'}) {
    switch (action) {
      case 'ortografia':
        return fixSpelling(text);
      case 'natural':
        return makeMoreNatural(text);
      case 'profesional':
        return makeMoreProfessional(text);
      case 'persuasivo':
        return makeMorePersuasive(text);
      case 'corto':
        return makeShorter(text);
      case 'largo':
        return makeLonger(text, tone);
      case 'tono':
        return applyTone(text, tone);
      default:
        return text;
    }
  }
}
