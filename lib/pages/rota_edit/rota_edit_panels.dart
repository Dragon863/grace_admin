import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grace_admin/pages/rota_edit/widgets/duty_card.dart';
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
  List<DutyCard> _dutyCards = [];
  bool loading = false;
  DateTime selectedDate = DateTime.now();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    _onSearchChanged(""); // Lists all users rather than searching
    super.initState();
    _loadDutyCards();
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

  DutyCard buildDutyCardFromDuty(Map duty) {
    return DutyCard(
      title: duty["title"],
      description: duty["description"] ?? "No Description",
      time: DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        int.parse(duty["time"].split(":")[0]),
        int.parse(duty["time"].split(":")[1]),
      ),
      onRemovePressed: () {
        setState(() {
          _dutyCards.removeWhere((element) => element.id == duty["id"]);
        });
      },
      id: duty["id"],
    );
  }

  void _loadDutyCards() async {
    loading = true;
    List toReturn = [];
    final roles =
        await context.read<AuthAPI>().client.from("roles").select("*").eq(
              "date",
              selectedDate.toIso8601String().split("T")[0],
            );
    for (final record in roles) {
      final user = await context
          .read<AuthAPI>()
          .client
          .from("profiles")
          .select("name")
          .eq("id", duty["profile_id"]);
      final duty = await context
          .read<AuthAPI>()
          .client
          .from("duties")
          .select("*")
          .eq("id", record["duty_id"]);
    }
    print(duties);
    /*final List<DutyCard> cards = [];
    for (final duty in duties) {
      cards.add(buildDutyCardFromDuty(duty));
    }
    setState(() {
      _dutyCards = cards;
      loading = false;
    });*/
  }

  void _saveAllDuties() async {
    final api = context.read<AuthAPI>();
    for (final DutyCard duty in _dutyCards) {
      final dutyData = {
        "id": duty.id,
        "title": duty.title,
        "description": duty.description,
        "time": duty.time.toString(),
      };
      await api.client.from("roles").upsert(dutyData);
    }
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
                      selectedDate = args.value;
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
                              onPressed: () {
                                _loadDutyCards();
                              },
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
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _dutyCards.isEmpty
                    ? loading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : const Center(
                            child: Text(
                              "No Duties Added",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                    : GridView.builder(
                        itemBuilder: (context, index) => _dutyCards[index],
                        itemCount: _dutyCards.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisExtent: 190,
                        ),
                        // Magic numbers. Don't touch.
                      )),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, "/duty_library");
          if (result != null) {
            final duty = buildDutyCardFromDuty(result as Map);
            setState(() {
              _dutyCards.add(duty);
            });
          }
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Duty"),
      ),
    );
  }
}
