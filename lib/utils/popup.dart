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
