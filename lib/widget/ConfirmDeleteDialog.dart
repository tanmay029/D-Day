import 'package:flutter/material.dart';

class ConfirmDeleteDialog extends StatelessWidget {
  final String taskName;
  final VoidCallback onDelete;

  const ConfirmDeleteDialog({
    Key? key,
    required this.taskName,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Delete Task"),
      content: Text("Are you sure you want to delete '$taskName'?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // Close dialog
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            onDelete();
            Navigator.of(context).pop(); // Close dialog after deleting
          },
          child: const Text("Delete", style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
