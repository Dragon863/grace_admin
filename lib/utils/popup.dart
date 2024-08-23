import 'package:flutter/material.dart';

Future<void> showErr(BuildContext context, String err) async {
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(content: SelectableText(err), actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Okay'),
      )
    ]),
  );
}

Future<void> showSuccess(BuildContext context, String text) async {
  await ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(text),
    duration: const Duration(seconds: 1),
    backgroundColor: Colors.green,
    behavior: SnackBarBehavior.floating,
    width: 300,
  ));
}
