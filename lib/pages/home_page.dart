import 'package:material_ui/material_ui.dart';
import 'package:todolist/data/database.dart';
import 'package:todolist/pages/add_page.dart';
import 'package:todolist/pages/util/ui_card.dart';

class HomePage extends StatefulWidget {
  const new({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ToDoBase db = ToDoBase();

  @override
  void initState() {
    super.initState();
    db.loadData();
  }

  void _checkBoxChanged(bool? value, int index) {
    setState(() => db.todoList[index][1] = !db.todoList[index][1]);
    db.updateData();
  }

  Future<void> createNewTask() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NavBarAddPage(index: null)),
    );
    if (!mounted) return;
    setState(() => db.loadData());
  }

  void openCurrentTask(int index) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NavBarAddPage(index: index)),
    );
    if (!mounted) return;
    setState(() => db.loadData());
  }

  void _deleteTask(int index) {
    setState(() => db.todoList.removeAt(index));
    db.updateData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 150,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 15,
          children: [
            Text(
              "Лист задач",
              style: TextStyle(
                color: Colors.white,
                fontSize: 35,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Заметок: ${db.todoList.length}",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(30),
        ),
        onPressed: () => createNewTask(),
        child: Icon(Icons.edit_square, color: Colors.teal[500], size: 25),
      ),
      body: ListView.builder(
        itemCount: db.todoList.length,
        itemBuilder: (context, index) => ToDoTileCard(
          taskName: db.todoList[index][0],
          isCompleted: db.todoList[index][1],
          description: db.todoList[index][2],
          onChanged: (value) => _checkBoxChanged(value, index),
          onDelete: (context) => _deleteTask(index),
          openButton: () => openCurrentTask(index),
        ),
      ),
    );
  }
}
