import 'package:flutter/material.dart';
import 'package:grace_admin/utils/api.dart';
import 'package:provider/provider.dart';

class RotaEditPageNew extends StatefulWidget {
  const RotaEditPageNew({super.key});

  @override
  State<RotaEditPageNew> createState() => _RotaEditPageNewState();
}

class _RotaEditPageNewState extends State<RotaEditPageNew> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grace Admin Panel',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 32, 109, 156),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              final api = context.read<AuthAPI>();
              await api.signOut();
              Navigator.pushNamed(context, '/splash');
            },
          )
        ],
      ),
      body: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          
        ],
      ),
    );
  }
}
