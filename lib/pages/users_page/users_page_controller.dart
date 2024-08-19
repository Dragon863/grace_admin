// Similar to controller for rota_edit page
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grace_admin/utils/api.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:grace_admin/utils/constants.dart';

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
        .where((user) => user[0] != 'Admin Service Account')
        .toList();
  } else {
    matchingUsers =
        users.where((user) => user[0] != 'Admin Service Account').toList();
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
                          final TextEditingController passwordController =
                              TextEditingController();
                          return AlertDialog(
                            title: const Text('Reset Password'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Enter the new password for ${user[0]}'),
                                TextField(
                                  controller: passwordController,
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
                                      context, passwordController.text);
                                },
                                child: const Text('Reset'),
                              )
                            ],
                          );
                        });
                    if (newPassword == null) return;
                    print("New password: $newPassword");
                    try {
                      final prefs = await SharedPreferences.getInstance();
                      final serviceKey = await prefs.getString('serviceKey');
                      if (serviceKey == null) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text(
                              'Service key error - please log out and log back in'),
                        ));
                        return;
                      }
                      await SupabaseClient(projectUrl, serviceKey,
                          authOptions: const AuthClientOptions(
                            autoRefreshToken: false,
                          )).auth.admin.updateUserById(user[1],
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
                      searchUsers(searchTerm, api, context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Error: $e'),
                      ));
                      searchUsers(searchTerm, api, context);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_forever),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Delete User'),
                            content: Text(
                                'Are you sure you want to delete ${user[0]}?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  final serviceKey =
                                      await prefs.getString('serviceKey');
                                  if (serviceKey == null) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content: Text(
                                          'Service key error - please log out and log back in'),
                                    ));
                                    return;
                                  }
                                  SupabaseClient(projectUrl, serviceKey,
                                      authOptions: const AuthClientOptions(
                                        autoRefreshToken: false,
                                      )).auth.admin.deleteUser(user[1]);
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text('${user[0]} deleted')));
                                },
                                child: const Text('Delete'),
                              )
                            ],
                          );
                        });
                    searchUsers(searchTerm, api, context);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: "Rename user",
                  onPressed: () async {
                    final newName = await showDialog<String>(
                        context: context,
                        builder: (context) {
                          final TextEditingController nameController =
                              TextEditingController();
                          return AlertDialog(
                            title: const Text('Rename User'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Enter the new name for ${user[0]}'),
                                TextField(
                                  controller: nameController,
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
                                  Navigator.pop(context, nameController.text);
                                },
                                child: const Text('Rename'),
                              )
                            ],
                          );
                        });
                    if (newName == null) return;
                    try {
                      final prefs = await SharedPreferences.getInstance();
                      final serviceKey = await prefs.getString('serviceKey');
                      if (serviceKey == null) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text(
                              'Service key error - please log out and log back in'),
                        ));
                        return;
                      }
                      await SupabaseClient(projectUrl, serviceKey,
                          authOptions: const AuthClientOptions(
                            autoRefreshToken: false,
                          )).auth.admin.updateUserById(user[1],
                          attributes: AdminUserAttributes(
                            userMetadata: {'display_name': newName},
                          ));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('${user[0]} renamed to $newName'),
                      ));
                      searchUsers(searchTerm, api, context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Error: $e'),
                      ));
                    }
                  },
                )
              ],
            ),
          ))
      .toList();
}
