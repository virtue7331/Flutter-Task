import 'package:hive/hive.dart';

class ToDoBase {
  var todoList = [];

  final _myBox = Hive.box('mybox');

  void loadData() {
    todoList = _myBox.get("TODOLIST", defaultValue: []);
  }

  void updateData() {
    _myBox.put("TODOLIST", todoList);
  }
}
