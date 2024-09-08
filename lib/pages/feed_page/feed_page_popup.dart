import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';

class FeedPagePopup extends StatefulWidget {
  @override
  _FeedPagePopupState createState() => _FeedPagePopupState();
}

class _FeedPagePopupState extends State<FeedPagePopup> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _btnNameController = TextEditingController();
  Color _selectedColor = Colors.red; // Default color selection

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Add button',
        style: GoogleFonts.rubik(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'URL',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _btnNameController,
            decoration: const InputDecoration(
              labelText: 'Button Text',
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _pickColor(context),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: _selectedColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Center(
                child: Text(
                  'Pick Colour',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop(null);
          },
        ),
        TextButton(
          child: const Text('OK'),
          onPressed: () {
            if (_urlController.text.isNotEmpty &&
                _btnNameController.text.isNotEmpty) {
              Navigator.of(context).pop({
                'color':
                    "${_selectedColor.red}, ${_selectedColor.green}, ${_selectedColor.blue}",
                'url': _urlController.text,
                'text': _btnNameController.text,
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Error: please fill out all fields."),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.red,
                  width: 400,
                ),
              );
              Navigator.of(context).pop(null);
            }
          },
        ),
      ],
    );
  }

  void _pickColor(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _selectedColor,
              onColorChanged: (Color color) {
                setState(() {
                  _selectedColor = color;
                });
              },
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
