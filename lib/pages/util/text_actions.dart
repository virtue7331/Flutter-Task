import 'package:material_ui/material_ui.dart';

// ignore: must_be_immutable
class MainButtonClass extends StatelessWidget {
  new({super.key, required this.backgroundColor});

  Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}

// ignore: must_be_immutable
class ButtonTextSize extends MainButtonClass {
  new({
    super.key,
    required super.backgroundColor,
    required this.size,
    required this.onChanged,
  });

  int size;
  final ValueChanged<int> onChanged;
  final listSize = List.generate(59, (int index) => 6 + index, growable: false);

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      style: MenuStyle(
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(12),
          ),
        ),
        maximumSize: WidgetStatePropertyAll(Size(double.infinity, 150)),
        backgroundColor: WidgetStateProperty.all(
          Color.fromARGB(255, 10, 10, 10),
        ),
        surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
        padding: WidgetStateProperty.all(EdgeInsets.zero),
      ),
      builder: (context, controller, child) => TextButton(
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
        child: Row(
          children: [
            Text(size.toString(), style: TextStyle(color: Colors.white)),
            Icon(
              controller.isOpen
                  ? Icons.arrow_drop_down_rounded
                  : Icons.arrow_drop_up_rounded,
              color: Colors.white,
            ),
          ],
        ),
      ),
      menuChildren: listSize
          .map(
            (e) => MenuItemButton(
              onPressed: () => onChanged(e),
              style: ButtonStyle(
                overlayColor: WidgetStatePropertyAll(Colors.teal[700]),
                backgroundColor: WidgetStatePropertyAll(backgroundColor),
                foregroundColor: WidgetStatePropertyAll(Colors.white),
              ),
              child: Text(e.toString(), textAlign: TextAlign.center),
            ),
          )
          .toList(),
    );
  }
}

// ignore: must_be_immutable
class ButtonTextColor extends MainButtonClass {
  new({super.key, required super.backgroundColor, required this.onChooseColor});

  ValueChanged<Color> onChooseColor;

  final listColor = [
    Colors.white, //0
    Colors.black, //1
    Colors.red, //2
    Colors.orange, //3
    Colors.yellow, //4
    Colors.green, //5
    Colors.lightBlue, //6
    const Color.fromARGB(255, 0, 108, 197), //7
    Colors.purple, //8
  ];

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      animated: true,
      style: MenuStyle(
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(12),
          ),
        ),
        maximumSize: WidgetStatePropertyAll(Size(double.infinity, 150)),
        padding: WidgetStatePropertyAll(EdgeInsets.zero),
        backgroundColor: WidgetStatePropertyAll(backgroundColor),
      ),
      builder: (context, controller, child) => IconButton(
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
        icon: Icon(
          Icons.format_color_fill_rounded,
          size: 20,
          color: Colors.white,
        ),
      ),
      menuChildren: listColor
          .map(
            (e) => MenuItemButton(
              onPressed: () => onChooseColor(e),
              child: Container(decoration: BoxDecoration(shape: BoxShape.circle, color: e), width: double.infinity, height: 25,),
            ),
          )
          .toList(), 
    );
  }
}
