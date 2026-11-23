import 'package:hive_flutter/hive_flutter.dart';
import 'package:material_ui/material_ui.dart';
import 'package:todolist/pages/home_page.dart';

void main() async {
  await Hive.initFlutter();

  await Hive.openBox('mybox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: const Color.fromARGB(255, 30, 30, 30),
        ),
        appBarTheme: AppBarThemeData(
          elevation: 0,
          backgroundColor: Colors.black,
          foregroundColor:  Colors.black,
        ),
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.white,
      ),
      home: HomePage(),
    );
  }
}
