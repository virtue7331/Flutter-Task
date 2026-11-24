import 'dart:io';
import 'dart:math';

import 'package:material_ui/material_ui.dart';

/// Контроллер текста со стилями для каждого символа:
/// размер, цвет, картинки внутри текста и чекбоксы в начале строки.
///
/// Картинка в тексте = один символ-заглушка (imageChar), а путь к файлу
/// лежит в списке images под тем же индексом. При отрисовке символ
/// заменяется на WidgetSpan с картинкой.
class StyledTextController extends TextEditingController {
  static const imageChar = '\uFFFC';

  /// Ширина картинок в тексте
  double imageWidth = 240;

  // null = «взять значение из основного стиля TextField»
  List<double?> sizes = [];
  List<Color?> colors = [];
  List<String?> images = []; // путь к файлу картинки или null

  bool _skipSync = false;

  bool get _consistent =>
      sizes.length == text.length &&
      colors.length == text.length &&
      images.length == text.length;

  bool get hasImages => images.any((p) => p != null);

  /// Текст без символов-заглушек (для превью заметки в списке)
  String get plainText => text.replaceAll(imageChar, '').trim();

  void _resetLists(int length) {
    sizes = List<double?>.filled(length, null, growable: true);
    colors = List<Color?>.filled(length, null, growable: true);
    images = List<String?>.filled(length, null, growable: true);
  }

  // Убрать [removed] элементов с позиции [at] и вставить [inserted] пустых
  void _splice<T>(List<T?> list, int at, int removed, int inserted) {
    list.removeRange(at, at + removed);
    list.insertAll(at, List<T?>.filled(inserted, null));
  }

  // Вызывается при любом изменении текста: сдвигаем стили вместе с ним
  @override
  set value(TextEditingValue newValue) {
    if (!_skipSync) _syncStyles(text, newValue.text);
    super.value = newValue;
  }

  void _syncStyles(String oldText, String newText) {
    if (oldText == newText) return;

    // Если списки по какой-то причине не совпали с текстом, сбрасываем их
    if (sizes.length != oldText.length ||
        colors.length != oldText.length ||
        images.length != oldText.length) {
      _resetLists(oldText.length);
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

    _splice(sizes, prefix, removed, inserted);
    _splice(colors, prefix, removed, inserted);
    _splice(images, prefix, removed, inserted);
  }

  // ---- Размер и цвет выделенного текста ----

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

  /// Сбросить индивидуальные размеры: весь текст берёт основной размер поля
  void clearSizes() {
    sizes = List<double?>.filled(text.length, null, growable: true);
    notifyListeners();
  }

  /// Сбросить индивидуальные цвета
  void clearColors() {
    colors = List<Color?>.filled(text.length, null, growable: true);
    notifyListeners();
  }

  // Возвращает безопасный диапазон или null, если выделения нет
  TextRange? _validRange(TextSelection? sel) {
    sel ??= selection;
    if (!sel.isValid || sel.isCollapsed || !_consistent) return null;
    return TextRange(
      start: sel.start.clamp(0, text.length),
      end: sel.end.clamp(0, text.length),
    );
  }

  // ---- Картинки внутри текста ----

  /// Вставить картинку в позицию курсора (на отдельной строке)
  void insertImage(String path) {
    if (!_consistent) _resetLists(text.length);

    final sel = selection.isValid
        ? selection
        : TextSelection.collapsed(offset: text.length);
    final start = sel.start.clamp(0, text.length);
    final end = sel.end.clamp(0, text.length);

    // Картинка на своей строке: переносы добавляем только там, где нужно
    final lineBreakBefore = start > 0 && text[start - 1] != '\n';
    final insert = '${lineBreakBefore ? '\n' : ''}$imageChar\n';
    final imageIndex = start + (lineBreakBefore ? 1 : 0);

    // Списки правим вручную, а не сравнением текста: рядом могут стоять
    // одинаковые символы, и сравнение сдвинуло бы путь не к той картинке
    _splice(sizes, start, end - start, insert.length);
    _splice(colors, start, end - start, insert.length);
    _splice(images, start, end - start, insert.length);
    images[imageIndex] = path;

    _skipSync = true;
    value = TextEditingValue(
      text: text.replaceRange(start, end, insert),
      selection: TextSelection.collapsed(offset: start + insert.length),
    );
    _skipSync = false;
    notifyListeners();
  }

  // ---- Чекбоксы в начале строки ----

  static const _unchecked = '☐ ';
  static const _checked = '☑ ';

  // Индекс начала строки, в которой стоит курсор
  int _lineStart(int offset) {
    if (offset <= 0) return 0;
    final i = text.lastIndexOf('\n', offset - 1);
    return i == -1 ? 0 : i + 1;
  }

  bool _hasBox(int lineStart) =>
      text.startsWith(_unchecked, lineStart) ||
      text.startsWith(_checked, lineStart);

  // Заменить часть текста и аккуратно сдвинуть курсор
  void _replace(int from, int to, String insert, int caret) {
    final newText = text.replaceRange(from, to, insert);
    int newCaret;
    if (caret >= to) {
      newCaret = caret + insert.length - (to - from);
    } else if (caret > from) {
      newCaret = from + insert.length;
    } else {
      newCaret = caret;
    }
    value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: min(newCaret, newText.length)),
    );
  }

  /// Кнопка: добавить чекбокс в начало текущей строки или убрать его
  void toggleCheckboxLine() {
    final offset = selection.isValid ? selection.start : text.length;
    final start = _lineStart(offset);
    if (_hasBox(start)) {
      _replace(start, start + 2, '', offset);
    } else {
      _replace(start, start, _unchecked, offset);
    }
  }

  /// Вызывать из onTap поля: если нажали на сам значок, переключить ☐ и ☑
  void toggleBoxAtCaret() {
    if (!selection.isValid || !selection.isCollapsed) return;
    final offset = selection.baseOffset;
    final start = _lineStart(offset);
    if (offset > start + 1 || !_hasBox(start)) return;
    final isChecked = text.startsWith('☑', start);
    _replace(start, start + 1, isChecked ? '☐' : '☑', offset);
  }

  // ---- Отрисовка ----

  // Собираем текст из кусочков с одинаковыми размером и цветом,
  // а вместо символов-заглушек вставляем картинки
  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    if (!_consistent) {
      return TextSpan(style: style, text: text);
    }

    final spans = <InlineSpan>[];
    int start = 0;
    while (start < text.length) {
      final path = images[start];

      // Картинка: один символ = один WidgetSpan
      if (path != null && text[start] == imageChar) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: _InlineImage(path: path, width: imageWidth),
          ),
        );
        start++;
        continue;
      }

      // Обычный текст: склеиваем символы с одинаковым стилем
      int end = start + 1;
      while (end < text.length &&
          images[end] == null &&
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
    'images': images,
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
    final im =
        (map['images'] as List?)?.map((e) => e as String?).toList() ??
        <String?>[];

    text = t; // сначала текст (он пересоздаст пустые списки)
    // Каждый список принимаем отдельно: у старых заметок images может не быть
    if (s.length == t.length) sizes = s;
    if (c.length == t.length) colors = c;
    if (im.length == t.length) images = im;
    notifyListeners();
  }
}

/// Картинка внутри текста
class _InlineImage extends StatelessWidget {
  const _InlineImage({required this.path, required this.width});

  final String path;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(path),
          width: width,
          cacheWidth: 800, // не держим в памяти фото в полном разрешении
          // файл могли удалить: показываем значок вместо ошибки
          errorBuilder: (context, error, stackTrace) => SizedBox(
            width: width,
            height: 80,
            child: const Center(
              child: Icon(Icons.broken_image_outlined, color: Colors.white54),
            ),
          ),
        ),
      ),
    );
  }
}
