import 'package:flutter/material.dart';
import 'package:grace_admin/utils/api.dart';
import 'package:provider/provider.dart';

class DutyTile extends StatefulWidget {
  final Map<dynamic, dynamic> duty;
  final void Function() onEdit;
  final void Function() onAdd;
  final void Function() onDeleteStart;
  final void Function() onDeleteEnd;

  const DutyTile({
    super.key,
    required this.duty,
    required this.onEdit,
    required this.onAdd,
    required this.onDeleteStart,
    required this.onDeleteEnd,
  });

  @override
  State<DutyTile> createState() => _DutyTileState();
}

class _DutyTileState extends State<DutyTile> {
  var deleted = false;

  @override
  Widget build(BuildContext context) {
    if (!deleted) {
      return ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.work_outline_rounded),
        ),
        title: Text(widget.duty["title"]),
        subtitle: Text(widget.duty["description"] ?? "No description"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                widget.onDeleteStart();
                await context
                    .read<AuthAPI>()
                    .client
                    .from("duties")
                    .delete()
                    .eq("id", widget.duty["id"]);

                setState(() {
                  deleted = true;
                });
                widget.onDeleteEnd();
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: widget.onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: widget.onAdd,
            ),
          ],
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
