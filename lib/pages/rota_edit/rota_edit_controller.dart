import 'package:flutter/material.dart';
import 'package:grace_admin/utils/api.dart';

Future<List<Widget>> searchUsers(String searchTerm, AuthAPI api) async {
  final List<List<String>> users = await api.getAllUsers();
  // Example data: [[Daniel Benge, 703c9cc2-1da3-478a-8924-18506550cce6]]
  print(users);

  if (searchTerm.isNotEmpty) {
    return users
        .where(
            (user) => user[0].toLowerCase().contains(searchTerm.toLowerCase()))
        .map((user) => LayoutBuilder(
              builder: (context, constraints) => Draggable(
                  feedback: Material(
                    child: SizedBox(
                      width: constraints.maxWidth,
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: Text(user[0]),
                      ),
                    ),
                  ),
                  child: Container(
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      title: Text(user[0]),
                    ),
                  )),
            ))
        .toList();
  }

  return users
      .map((user) => ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(user[0]),
          ))
      .toList();
}
