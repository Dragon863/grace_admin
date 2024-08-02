import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grace_admin/pages/rota_edit/rota_edit_controller.dart';
import 'package:grace_admin/utils/api.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'dart:async';

class PanelledRotaEditPage extends StatefulWidget {
  const PanelledRotaEditPage({super.key});

  @override
  State<PanelledRotaEditPage> createState() => _PanelledRotaEditPageState();
}

class _PanelledRotaEditPageState extends State<PanelledRotaEditPage> {
  List<Widget> searchResults = [];
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final widgetResults = await searchUsers(query, context.read<AuthAPI>());
      setState(() {
        searchResults = widgetResults;
      });
    });
  }

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
                width: 2.0,
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
                        width: 2.0,
                      ),
                    ),
                  ),
                  height: MediaQuery.of(context).size.height * 0.4,
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        SearchBar(
                          hintText: "Search Users",
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          padding: WidgetStateProperty.all<EdgeInsets>(
                              const EdgeInsets.symmetric(horizontal: 15)),
                          leading: const Icon(Icons.search),
                          shadowColor: WidgetStateColor.transparent,
                          onChanged: _onSearchChanged,
                        ),
                        const SizedBox(height: 5),
                        Expanded(
                          child: ListView(
                            shrinkWrap: true,
                            children: searchResults,
                          ),
                        ),
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
            child: Column(
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: Card(
                          child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                children: [
                                  Icon(Icons.work),
                                  const SizedBox(width: 10),
                                  Text("Duty Name"),
                                ],
                              )), // TODO: create separate card for this
                        ))
                      ],
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        // Squircle

        icon: const Icon(Icons.add),
        label: const Text("Add Duty"),
      ),
    );
  }
}
