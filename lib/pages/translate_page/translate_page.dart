import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grace_admin/utils/api.dart';
import 'package:provider/provider.dart';

class TranslatePage extends StatefulWidget {
  const TranslatePage({super.key});

  @override
  State<TranslatePage> createState() => _TranslatePageState();
}

class _TranslatePageState extends State<TranslatePage> {
  final TextEditingController _codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Grace Admin Panel',
            style: GoogleFonts.rubik(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 32, 109, 156),
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
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
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color.fromARGB(255, 32, 109, 156),
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500, minWidth: 400),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Update Code',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                          "Copy the code from the microsoft translate app and paste it here, then press update"),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.translate),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 150,
                            child: TextField(
                              controller: _codeController,
                              decoration: const InputDecoration(
                                hintText: 'Translation Code',
                              ),
                            ),
                          ),
                          const Spacer(),
                          FilledButton(
                            onPressed: () async {
                              final api = context.read<AuthAPI>();
                              await api.client.from("translate").update({
                                'code': _codeController.text,
                              }).eq(
                                  "id", "7e91a5f1-fe0c-4c79-9688-6ffd382295b4");
                              _codeController.clear();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Code updated'),
                                ),
                              );
                            },
                            child: const Text('Update'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
