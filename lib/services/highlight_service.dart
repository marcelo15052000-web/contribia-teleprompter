import 'package:flutter/material.dart';

/// highlight_service.dart — "Inteligencia para lectura"
/// Convierte el texto del guion en una lista de InlineSpan resaltando
/// automáticamente números, porcentajes, leyes/artículos, fechas,
/// valores monetarios, palabras difíciles (*palabra*) y pausas ([pausa]).
class HighlightService {
  static const _colorNumero = Color(0xFFFFD54F);
  static const _colorPorcentaje = Color(0xFF4FC3F7);
  static const _colorFecha = Color(0xFFAED581);
  static const _colorDinero = Color(0xFF81C784);
  static const _colorLey = Color(0xFFFF8A65);
  static const _colorPausa = Colors.white70;
  static const _colorDificil = Color(0xFFFF3B30);

  static final RegExp _pausaRe = RegExp(r'\[pausa\]', caseSensitive: false);
  static final RegExp _dificilRe = RegExp(r'\*([^*]+)\*');
  static final RegExp _dineroRe = RegExp(r'(\$\s?\d[\d.,]*|\bUSD\s?\d[\d.,]*)');
  static final RegExp _porcentajeRe = RegExp(r'\b\d+([.,]\d+)?\s?%');
  static final RegExp _fechaRe = RegExp(
      r'\b\d{1,2}[/-]\d{1,2}[/-]\d{2,4}\b|\b\d{1,2}\s+de\s+(enero|febrero|marzo|abril|mayo|junio|julio|agosto|septiembre|octubre|noviembre|diciembre)\s+(de\s+)?\d{4}\b',
      caseSensitive: false);
  static final RegExp _leyRe =
      RegExp(r'\b(art(í|i)culo|art\.)\s?\d+[a-zA-Z\-]*|\bley\s+(orgánica\s+)?(de\s+)?[\wÁÉÍÓÚáéíóúñÑ\s]{0,40}?(?=[.,;\n]|$)',
          caseSensitive: false);
  static final RegExp _numeroRe = RegExp(r'\b\d{4,}\b');

  /// Marca de rango con su color asociado, usado para resolver
  /// superposiciones y evitar doble-resaltado del mismo tramo.
  static List<_Match> _collectMatches(String text, HighlightOptions opts) {
    final matches = <_Match>[];

    for (final m in _pausaRe.allMatches(text)) {
      matches.add(_Match(m.start, m.end, _colorPausa, replaceText: '⏸ pausa', bold: false, background: true));
    }
    for (final m in _dificilRe.allMatches(text)) {
      matches.add(_Match(m.start, m.end, _colorDificil, replaceText: m.group(1), underline: true));
    }
    if (opts.money) {
      for (final m in _dineroRe.allMatches(text)) {
        matches.add(_Match(m.start, m.end, _colorDinero, bold: true));
      }
    }
    if (opts.numbers) {
      for (final m in _porcentajeRe.allMatches(text)) {
        matches.add(_Match(m.start, m.end, _colorPorcentaje, bold: true));
      }
    }
    if (opts.dates) {
      for (final m in _fechaRe.allMatches(text)) {
        matches.add(_Match(m.start, m.end, _colorFecha));
      }
    }
    if (opts.laws) {
      for (final m in _leyRe.allMatches(text)) {
        matches.add(_Match(m.start, m.end, _colorLey, bold: true));
      }
    }
    if (opts.numbers) {
      for (final m in _numeroRe.allMatches(text)) {
        matches.add(_Match(m.start, m.end, _colorNumero));
      }
    }

    // Ordena por posición y elimina solapamientos (el primero encontrado gana)
    matches.sort((a, b) => a.start.compareTo(b.start));
    final resolved = <_Match>[];
    int lastEnd = -1;
    for (final m in matches) {
      if (m.start >= lastEnd) {
        resolved.add(m);
        lastEnd = m.end;
      }
    }
    return resolved;
  }

  /// Construye los spans para un [RichText] a partir del texto crudo.
  static List<InlineSpan> buildSpans(
    String text, {
    required double fontSize,
    required Color baseColor,
    required HighlightOptions options,
  }) {
    final matches = _collectMatches(text, options);
    final baseStyle = TextStyle(
      color: baseColor,
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      height: 1.4,
    );

    if (matches.isEmpty) {
      return [TextSpan(text: text, style: baseStyle)];
    }

    final spans = <InlineSpan>[];
    int cursor = 0;
    for (final m in matches) {
      if (m.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, m.start), style: baseStyle));
      }
      spans.add(TextSpan(
        text: m.replaceText ?? text.substring(m.start, m.end),
        style: baseStyle.copyWith(
          color: m.color,
          fontWeight: m.bold ? FontWeight.w800 : baseStyle.fontWeight,
          decoration: m.underline ? TextDecoration.underline : null,
          decorationStyle: m.underline ? TextDecorationStyle.wavy : null,
          decorationColor: m.underline ? _colorDificil : null,
          backgroundColor: m.background ? Colors.white24 : null,
        ),
      ));
      cursor = m.end;
    }
    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor), style: baseStyle));
    }
    return spans;
  }
}

class HighlightOptions {
  final bool numbers;
  final bool laws;
  final bool dates;
  final bool money;

  const HighlightOptions({
    this.numbers = true,
    this.laws = true,
    this.dates = true,
    this.money = true,
  });
}

class _Match {
  final int start;
  final int end;
  final Color color;
  final String? replaceText;
  final bool bold;
  final bool underline;
  final bool background;

  _Match(
    this.start,
    this.end,
    this.color, {
    this.replaceText,
    this.bold = false,
    this.underline = false,
    this.background = false,
  });
}
