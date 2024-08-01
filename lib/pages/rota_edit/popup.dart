import 'package:flutter/material.dart';

Future<String?> showInputDialog(BuildContext context) async {
  TextEditingController _textFieldController = TextEditingController();

  String? inputText;
  await showDialog<String?>(
    context: context,
    barrierDismissible: true, // user can tap outside of the box to dismiss
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Please enter role name'),
        content: TextField(
          controller: _textFieldController,
          decoration: const InputDecoration(hintText: "Type here..."),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              inputText = _textFieldController.text;
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
  return inputText;
}
