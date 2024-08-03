import 'package:flutter/material.dart';
import 'package:grace_admin/utils/api.dart';

Future<List<Widget>> searchUsers(String searchTerm, AuthAPI api) async {
  final List<List<String>> users = await api.getAllUsers();
  // Example data: [[Daniel Benge, 703c9cc2-1da3-478a-8924-18506550cce6]]
  List<List<String>> matchingUsers;

  if (searchTerm.isNotEmpty) {
    matchingUsers = users
        .where(
            (user) => user[0].toLowerCase().contains(searchTerm.toLowerCase()))
        .toList();
  } else {
    matchingUsers = users;
  }
  return matchingUsers
      .map(
        (user) => LayoutBuilder(builder: (context, constraints) {
          return Draggable<List<String>>(
              data: user,
              feedback: Material(
                child: SizedBox(
                  width: constraints.maxWidth,
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text(user[0]),
                    trailing: const Icon(Icons.drag_indicator),
                  ),
                ),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text(user[0]),
                trailing: const Icon(Icons.drag_indicator),
              ));
        }),
      )
      .toList();
}

