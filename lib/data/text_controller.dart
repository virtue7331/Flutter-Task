import 'dart:math';

import 'package:material_ui/material_ui.dart';

class StyledTextController extends TextEditingController {
  // null = «взять значение из основного стиля TextField»
  List<double?> sizes = [];
  List<Color?> colors = [];

  // Вызывается при любом изменении текста: сдвигаем стили вместе с ним
  @override
  set value(TextEditingValue newValue) {
    _syncStyles(text, newValue.text);
    super.value = newValue;
  }

  void _syncStyles(String oldText, String newText) {
    if (oldText == newText) return;

    // Если списки по какой-то причине не совпали с текстом, сбрасываем их
    if (sizes.length != oldText.length || colors.length != oldText.length) {
      sizes = List<double?>.filled(oldText.length, null, growable: true);
      colors = List<Color?>.filled(oldText.length, null, growable: true);
    }

    // Общее начало и общий конец старого и нового текста
    final minLen = min(oldText.length, newText.length);
    int prefix = 0;
    while (prefix < minLen && oldText[prefix] == newText[prefix]) {
      prefix++;
    }
    int suffix = 0;
    while (suffix < minLen - prefix &&
        oldText[oldText.length - 1 - suffix] ==
            newText[newText.length - 1 - suffix]) {
      suffix++;
    }

    final removed = oldText.length - prefix - suffix;
    final inserted = newText.length - prefix - suffix;

    sizes.removeRange(prefix, prefix + removed);
    sizes.insertAll(prefix, List<double?>.filled(inserted, null));
    colors.removeRange(prefix, prefix + removed);
    colors.insertAll(prefix, List<Color?>.filled(inserted, null));
  }

  /// Применить размер к выделенному тексту.
  /// [sel] можно передать явно, если выделение могло сброситься.
  void applySize(double? size, [TextSelection? sel]) {
    final range = _validRange(sel);
    if (range == null) return;
    for (int i = range.start; i < range.end; i++) {
      sizes[i] = size;
    }
    notifyListeners(); // перерисовать поле
  }

  /// Применить цвет к выделенному тексту.
  void applyColor(Color? color, [TextSelection? sel]) {
    final range = _validRange(sel);
    if (range == null) return;
    for (int i = range.start; i < range.end; i++) {
      colors[i] = color;
    }
    notifyListeners();
  }

  // Возвращает безопасный диапазон или null, если выделения нет
  TextRange? _validRange(TextSelection? sel) {
    sel ??= selection;
    if (!sel.isValid || sel.isCollapsed) return null;
    if (sizes.length != text.length || colors.length != text.length) {
      return null;
    }
    return TextRange(
      start: sel.start.clamp(0, text.length),
      end: sel.end.clamp(0, text.length),
    );
  }

  // Собираем текст из кусочков с одинаковыми размером и цветом
  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    if (sizes.length != text.length || colors.length != text.length) {
      return TextSpan(style: style, text: text);
    }

    final spans = <TextSpan>[];
    int start = 0;
    while (start < text.length) {
      int end = start + 1;
      while (end < text.length &&
          sizes[end] == sizes[start] &&
          colors[end] == colors[start]) {
        end++;
      }
      final hasStyle = sizes[start] != null || colors[start] != null;
      spans.add(
        TextSpan(
          text: text.substring(start, end),
          style: hasStyle
              ? TextStyle(fontSize: sizes[start], color: colors[start])
              : null,
        ),
      );
      start = end;
    }
    return TextSpan(style: style, children: spans);
  }

  // ---- Сохранение в Hive (Hive умеет хранить Map, списки, числа, строки) ----

  Map<String, dynamic> toMap() => {
    'text': text,
    'sizes': sizes,
    'colors': colors.map((c) => c?.toARGB32()).toList(),
  };

  void loadFromMap(Map map) {
    final t = map['text'] as String? ?? '';
    final s =
        (map['sizes'] as List?)?.map((e) => (e as num?)?.toDouble()).toList() ??
        <double?>[];
    final c =
        (map['colors'] as List?)
            ?.map((e) => e == null ? null : Color(e as int))
            .toList() ??
        <Color?>[];

    text = t; // сначала текст (он пересоздаст пустые списки)
    if (s.length == t.length && c.length == t.length) {
      sizes = s;
      colors = c;
    }
    notifyListeners();
  }
}
