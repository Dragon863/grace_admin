import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grace_admin/utils/api.dart';
import 'package:grace_admin/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class PrintPage extends StatefulWidget {
  const PrintPage({super.key});

  @override
  State<PrintPage> createState() => _PrintPageState();
}

class _PrintPageState extends State<PrintPage> {
  String month = 'January';

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
        iconTheme: const IconThemeData(
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
                          'Print Rota',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                            "Pick a month below to print a paper copy the rota for that month."),
                        const SizedBox(height: 16),
                        // Month picker
                        Row(
                          children: [
                            DropdownMenu<String>(
                              initialSelection: month,
                              dropdownMenuEntries: const [
                                DropdownMenuEntry<String>(
                                    value: 'January', label: 'January'),
                                DropdownMenuEntry<String>(
                                    value: 'February', label: 'February'),
                                DropdownMenuEntry<String>(
                                    value: 'March', label: 'March'),
                                DropdownMenuEntry<String>(
                                    value: 'April', label: 'April'),
                                DropdownMenuEntry<String>(
                                    value: 'May', label: 'May'),
                                DropdownMenuEntry<String>(
                                    value: 'June', label: 'June'),
                                DropdownMenuEntry<String>(
                                    value: 'July', label: 'July'),
                                DropdownMenuEntry<String>(
                                    value: 'August', label: 'August'),
                                DropdownMenuEntry<String>(
                                    value: 'September', label: 'September'),
                                DropdownMenuEntry<String>(
                                    value: 'October', label: 'October'),
                                DropdownMenuEntry<String>(
                                    value: 'November', label: 'November'),
                                DropdownMenuEntry<String>(
                                    value: 'December', label: 'December'),
                              ],
                              onSelected: (String? newValue) {
                                setState(() {
                                  month = newValue!;
                                });
                              },
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                            IconButton(
                              icon: const Icon(Icons.print_outlined),
                              onPressed: () async {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Printing...'),
                                  ),
                                );
                                await launchUrlString(
                                  '$printMicroserviceUrl/?month=$month',
                                );
                              },
                            )
                          ],
                        ),
                      ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
