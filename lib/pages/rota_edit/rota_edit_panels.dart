import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grace_admin/utils/api.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class PanelledRotaEditPage extends StatefulWidget {
  const PanelledRotaEditPage({super.key});

  @override
  State<PanelledRotaEditPage> createState() => _PanelledRotaEditPageState();
}

class _PanelledRotaEditPageState extends State<PanelledRotaEditPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Grace Admin Panel',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
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
      body: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.3,
            decoration: const BoxDecoration(
                border: Border(
              right: BorderSide(
                color: Color.fromARGB(255, 32, 109, 156),
                width: 3.0,
              ),
            )),
            child: Column(
              children: [
                Expanded(
                  child: SfDateRangePicker(
                    onSelectionChanged:
                        (DateRangePickerSelectionChangedArgs args) {
                      print(args.value);
                    },
                    selectionMode: DateRangePickerSelectionMode.single,
                    initialSelectedDate: DateTime.now(),
                    selectionColor: const Color.fromARGB(255, 32, 109, 156),
                    selectionTextStyle: GoogleFonts.rubik(
                      fontWeight: FontWeight.bold,
                    ),
                    headerStyle: DateRangePickerHeaderStyle(
                      textAlign: TextAlign.center,
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      textStyle: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    headerHeight: 70,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    showNavigationArrow: true,
                    monthViewSettings: DateRangePickerMonthViewSettings(
                      viewHeaderHeight: 50,
                      viewHeaderStyle: DateRangePickerViewHeaderStyle(
                        textStyle: GoogleFonts.rubik(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Color.fromARGB(255, 32, 109, 156),
                        width: 3.0,
                      ),
                    ),
                  ),
                  height: MediaQuery.of(context).size.height * 0.2,
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.person_2_outlined),
                            Text("  Users: ",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(" 1")
                          ],
                        ),
                        const Row(
                          children: [
                            Icon(Icons.work_outline),
                            Text("  Duties: ",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(" 12")
                          ],
                        ),
                        const Row(
                          children: [
                            Icon(Icons.settings_outlined),
                            Text("  Version: ",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(" 1.0.0-alpha")
                          ],
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.save),
                              label: const Text(
                                "Save",
                              ),
                              onPressed: () {},
                            ),
                            const Spacer(),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.delete_forever),
                              label: const Text(
                                "Discard",
                              ),
                              onPressed: () {},
                            ),
                            const Spacer(),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.undo),
                              label: const Text(
                                "Undo",
                              ),
                              onPressed: () {},
                            ),
                            const Spacer(),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.redo),
                              label: const Text(
                                "Redo",
                              ),
                              onPressed: () {},
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.7,
            child: const Column(
              children: [
                FlutterLogo(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
