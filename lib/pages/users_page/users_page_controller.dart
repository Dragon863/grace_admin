// Similar to controller for rota_edit page
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grace_admin/utils/api.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

String _generatePassword() {
  String upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  String lower = 'abcdefghijklmnopqrstuvwxyz';
  String numbers = '1234567890';
  String symbols = '!@#\$%^&*()<>,./';
  int passLength = 16;
  String seed = upper + lower + numbers + symbols;
  String password = '';
  List<String> list = seed.split('').toList();
  Random rand = Random();

  for (int i = 0; i < passLength; i++) {
    int index = rand.nextInt(list.length);
    password += list[index];
  }
  return password;
}

Future<List<Widget>> searchUsers(
    String searchTerm, AuthAPI api, BuildContext context) async {
  final List<List<String>> users = await api.getAllUsers();
  // Example data: [[User's Name, ffffffff-ffff-ffff-ffff-ffffffffffff]]
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
      .map((user) => ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Text(user[0]),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.password_outlined),
                  onPressed: () async {
                    final api = context.read<AuthAPI>();
                    //final newPassword = _generatePassword();
                    // Instead of this we will prompt the user asking for the new password
                    final newPassword = await showDialog<String>(
                        context: context,
                        builder: (context) {
                          final TextEditingController _passwordController =
                              TextEditingController();
                          return AlertDialog(
                            title: const Text('Reset Password'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Enter the new password for ${user[0]}'),
                                TextField(
                                  controller: _passwordController,
                                  obscureText: true,
                                )
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(
                                      context, _passwordController.text);
                                },
                                child: const Text('Reset'),
                              )
                            ],
                          );
                        });
                    if (newPassword == null) return;
                    print(user[1]);
                    await api.client.auth.admin.updateUserById(user[1],
                        attributes: AdminUserAttributes(
                          password: newPassword,
                        ));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: SelectableText(
                          'Password for ${user[0]} reset to $newPassword'),
                      action: SnackBarAction(
                        label: 'Copy',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: newPassword));
                        },
                      ),
                    ));
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_forever),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {},
                )
              ],
            ),
          ))
      .toList();
}
