import 'package:hive_flutter/adapters.dart';
import 'package:material_ui/material_ui.dart';
import 'package:todolist/data/database.dart';
import 'package:todolist/data/text_controller.dart';
import 'package:todolist/pages/util/text_actions.dart';

// ignore: must_be_immutable
class NavBarAddPage extends StatefulWidget {
  final int? index;

  const new({super.key, required this.index});

  @override
  State<NavBarAddPage> createState() => _NavBarAddPageState();
}

class _NavBarAddPageState extends State<NavBarAddPage> {
  final _labelFocusNode = FocusNode();
  final _descrFocusNode = FocusNode();

  bool _focused = false;
  bool get _isEditing => widget.index != null;

  Color? backgroundColor = const Color.fromARGB(255, 10, 10, 10);

  int _fontSize = 15;
  var _lastTextSelection = const TextSelection.collapsed(offset: 0);

  Color _chooseColor = Colors.white;

  final db = ToDoBase();

  final _controllerLabel = TextEditingController();
  final _controllerDescr = StyledTextController();

  @override
  void dispose() {
    _controllerLabel.dispose();
    _controllerDescr.dispose();
    _labelFocusNode.dispose();
    _descrFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    db.loadData();

    if (_isEditing) {
      final task = db.todoList[widget.index!];
      _controllerLabel.text = task[0];

      // у старых заметок четвёртого элемента нет
      final styles = task.length > 3 ? task[3] : null;
      if (styles != null) {
        _controllerDescr.loadFromMap(styles); // текст + размеры + цвета
      } else {
        _controllerDescr.text = task[2];
      }
    }

    final box = Hive.box('mybox');
    _fontSize = box.get('FONT_SIZE', defaultValue: 15);
    _chooseColor = Color(
      box.get('COLOR', defaultValue: Colors.white.toARGB32()),
    );

    _controllerDescr.addListener(() {
      final s = _controllerDescr.selection;
      if (s.isValid && !s.isCollapsed) _lastTextSelection = s;
    });

    _labelFocusNode.addListener(
      () => setState(() => _focused = _labelFocusNode.hasFocus),
    );
  }

  void _saveTask() {
    var labelText = _controllerLabel.text;
    var description = _controllerDescr.text;
    Map<String, dynamic>? styles = _controllerDescr.toMap();

    // если описания нет, название становится описанием
    if (description.isEmpty && labelText.isNotEmpty) {
      description = labelText;
      labelText = '';
      styles = null; // у перенесённого текста форматирования нет
    }

    if (_isEditing) {
      final task = db.todoList[widget.index!];
      task[0] = labelText;
      task[2] = description;
      if (task.length > 3) {
        task[3] = styles;
      } else {
        task.add(styles); // старая заметка без четвёртого элемента
      }
    } else {
      db.todoList.add([labelText, false, description, styles]);
    }

    db.updateData();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween(end: _focused ? 160 : kToolbarHeight),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 20, 20, 20),
          appBar: renderAppBar(value),
          body: renderBody(),
          bottomNavigationBar: renderNavBar(),
        );
      },
    );
  }

  Widget? renderNavBar() => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
    child: BottomAppBar(
      height: kBottomNavigationBarHeight,
      color: backgroundColor,
      elevation: 0,
      child: ExcludeFocus(
        child: Row(
          children: [
            ButtonTextSize(
              backgroundColor: backgroundColor,
              size: _fontSize,
              onChanged: (value) {
                if (!_lastTextSelection.isCollapsed) {
                  _controllerDescr.applySize(
                    value.toDouble(),
                    _lastTextSelection,
                  );
                  _lastTextSelection = const TextSelection.collapsed(offset: 0);
                } else {
                  setState(() => _fontSize = value);
                  Hive.box('mybox').put('FONT_SIZE', value);
                }
                _descrFocusNode.requestFocus();
              },
            ),
            ButtonTextColor(
              backgroundColor: backgroundColor,
              onChooseColor: (value) {
                if (!_lastTextSelection.isCollapsed) {
                  _controllerDescr.applyColor(value, _lastTextSelection);
                  _lastTextSelection = const TextSelection.collapsed(offset: 0);
                } else {
                  setState(() => _chooseColor = value);
                  Hive.box('mybox').put('COLOR', value.toARGB32());
                }
                _descrFocusNode.requestFocus();
              },
            ),
          ],
        ),
      ),
    ),
  );

  Widget? renderBody() => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () => _labelFocusNode.unfocus(),
    child: Padding(
      padding: const EdgeInsets.only(top: 80, bottom: 80),
      child: TextField(
        focusNode: _descrFocusNode,
        controller: _controllerDescr,
        expands: true,
        minLines: null,
        maxLines: null,
        textAlignVertical: TextAlignVertical.top,
        readOnly: false,
        textCapitalization: TextCapitalization.sentences,
        style: TextStyle(color: _chooseColor, fontSize: _fontSize.toDouble()),
        decoration: const InputDecoration(
          filled: true,
          fillColor: Colors.black,
          border: InputBorder.none,
        ),
      ),
    ),
  );

  AppBar renderAppBar(num value) => AppBar(
    leadingWidth: 40,
    toolbarHeight: value.toDouble(),
    leading: IconButton(
      color: Colors.white,
      onPressed: () =>
          _controllerLabel.text.isNotEmpty || _controllerDescr.text.isNotEmpty
          ? _saveTask()
          : Navigator.pop(context),
      icon: Icon(
        !_focused
            ? Icons.arrow_back_ios_new_outlined
            : Icons.arrow_forward_ios_rounded,
      ),
    ),
    title: TextField(
      controller: _controllerLabel,
      textCapitalization: TextCapitalization.sentences,
      style: TextStyle(color: Colors.white, fontSize: 20),
      focusNode: _labelFocusNode,
      maxLines: _focused ? 4 : 1,
      decoration: InputDecoration(
        filled: false,
        hintText: "Название",
        hintStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        border: InputBorder.none,
      ),
      // controller: , //Save and view text
    ),
    bottom: PreferredSize(
      preferredSize: Size.fromHeight(kBottomNavigationBarHeight - 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.add),
            color: Colors.white,
            highlightColor: Colors.teal[500],
          ),
        ],
      ),
    ),
  );
}
