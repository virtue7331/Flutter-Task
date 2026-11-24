import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:material_ui/material_ui.dart';

// ignore: must_be_immutable
class ToDoTileCard extends StatelessWidget {
  String taskName, description;
  final bool isCompleted;
  Function(bool? value)? onChanged;
  Function(BuildContext context)? onDelete;
  Function()? openButton;

  ToDoTileCard({
    super.key,
    required this.taskName,
    required this.description,
    required this.isCompleted,
    required this.onChanged,
    required this.onDelete,
    required this.openButton,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, right: 15, top: 15),
      child: InkWell(
        onTap: openButton,
        highlightColor: Colors.black,
        focusColor: Colors.black,
        hoverColor: Colors.black,
        splashColor: Colors.black,
        overlayColor: WidgetStateColor.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          verticalDirection: VerticalDirection.up,
          spacing: 6,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 18.0, bottom: 15),
              child: Text(
                taskName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            Slidable(
              endActionPane: ActionPane(
                extentRatio: 0.4,
                motion: const StretchMotion(),
                children: [
                  SlidableAction(
                    onPressed: onDelete,
                    iconSize: 25,
                    icon: Icons.delete_forever,
                    borderRadius: BorderRadius.circular(16),
                    backgroundColor: Colors.red.shade800,
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: const Color.fromARGB(255, 35, 35, 35),
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: FittedBox(
                        child: Checkbox(
                          side: BorderSide(color: Colors.teal.shade800),
                          splashRadius: 0,
                          value: isCompleted,
                          onChanged: onChanged,
                          activeColor: Colors.teal[500],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
