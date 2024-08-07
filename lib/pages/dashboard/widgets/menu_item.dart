import 'package:flutter/material.dart';

class DashMenuItem extends StatelessWidget {
  final String title;
  final IconData iconData;
  final Function()? onTap;
  final bool selected;

  const DashMenuItem({
    Key? key,
    required this.title,
    required this.iconData,
    required this.onTap,
    required this.selected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:
            selected ? const Color.fromARGB(255, 209, 234, 255) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        title: Text(title, style: const TextStyle(color: Colors.black)),
        leading: Icon(iconData, color: Colors.black),
        onTap: () {
          onTap!();
        },
      ),
    );
  }
}
