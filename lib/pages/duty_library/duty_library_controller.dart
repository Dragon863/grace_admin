import 'package:flutter/material.dart';
import 'package:grace_admin/utils/api.dart';

Future<List<Widget>> searchDuties(String searchTerm, AuthAPI api) async {
  final duties = await api.client.from("duties").select();
  // Example data: [[User's Name, ffffffff-ffff-ffff-ffff-ffffffffffff]]
  List matchingDuties;

  if (searchTerm.isNotEmpty) {
    matchingDuties = duties
        .where((user) =>
            user["title"].toLowerCase().contains(searchTerm.toLowerCase()))
        .toList();
  } else {
    matchingDuties = duties;
  }
  print(matchingDuties);
  return matchingDuties
      .map(
        (duty) => ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.work_outline_rounded),
          ),
          title: Text(duty["title"]),
          trailing: const Icon(Icons.add),
        ),
      )
      .toList();
}
