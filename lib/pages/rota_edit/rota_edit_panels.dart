import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grace_admin/pages/rota_edit/widgets/duty_card.dart';
import 'package:grace_admin/pages/rota_edit/rota_edit_controller.dart';
import 'package:grace_admin/utils/api.dart';
import 'package:grace_admin/utils/popup.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';

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
      onRemovePressed: () async {
        setState(() {
          _dutyCards.removeWhere((element) => element.id == duty["id"]);
        });
        // Delete with API
        final api = context.read<AuthAPI>();
        await api.client.from("roles").delete().eq("id", duty['row_id']);
        _loadDutyCards();
      },
      id: duty["id"],
      row_id: duty["row_id"],
      acceptedUser: duty["accepted_user"],
    );
  }

  void _loadDutyCards() async {
    setState(() {
      loading = true;
    });
    List<DutyCard> toReturn = [];
    final roles =
        await context.read<AuthAPI>().client.from("roles").select("*").eq(
              "date",
              selectedDate.toIso8601String().split("T")[0],
            );
    for (final record in roles) {
      final duty = await context
          .read<AuthAPI>()
          .client
          .from("duties")
          .select("*")
          .eq("id", record["duty_id"])
          .single();

      if (record['profile_id'] != null) {
        final user = await context
            .read<AuthAPI>()
            .client
            .from("profiles")
            .select("full_name")
            .eq("id", record["profile_id"])
            .single();
        duty["accepted_user"] = <String>[
          user["full_name"],
          record["profile_id"]
        ];
        duty["row_id"] = record["id"];
        toReturn.add(buildDutyCardFromDuty(duty));
        setState(() {
          loading = false;
        });
      } else {
        duty["row_id"] = record["id"];
        toReturn.add(buildDutyCardFromDuty(duty));
        setState(() {
          loading = false;
        });
      }
    }

    setState(() {
      _dutyCards = toReturn;
      loading = false;
    });
  }

  void _saveAllDuties() async {
    try {
      final api = context.read<AuthAPI>();
      // print("Saving duties");

      // Collect all duty data
      List<Map<String, dynamic>> dutiesData = _dutyCards.map((card) {
        return {
          "id": card.row_id, // Now include the primary key :)
          "duty_id": card.id,
          "profile_id":
              card.acceptedUser != null ? card.acceptedUser![1] : null,
          "date": selectedDate.toIso8601String().split("T")[0],
        };
      }).toList();

      // Perform batch update
      try {
        await api.client.from("roles").upsert(dutiesData, onConflict: "id");
        showSuccess(context, "Successfully saved");
      } catch (e) {
        showErr(context, "Error whilst saving: ${e.toString()}");
      }
    } catch (e) {
      showErr(context, "Error whilst saving: ${e.toString()}");
    }
  }

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
        // automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Show a dialog to confirm if the user wants to save
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Save Changes?"),
                    content: const Text(
                        "Do you want to save changes before leaving?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: const Text("No"),
                      ),
                      TextButton(
                        onPressed: () {
                          _saveAllDuties();
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: const Text("Yes"),
                      ),
                    ],
                  );
                });
          },
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
      body: Stack(
        children: [
          Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.3,
                decoration: const BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: Color.fromARGB(255, 32, 109, 156),
                      width: 2.0,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: SfDateRangePicker(
                        onSelectionChanged:
                            (DateRangePickerSelectionChangedArgs args) async {
                          selectedDate = args.value;
                          setState(() {
                            _dutyCards = [];
                            _loadDutyCards();
                          });
                          _saveAllDuties();
                          showSuccess(context, "Successfully saved");
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
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
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
                                  onPressed: _saveAllDuties,
                                ),
                                const Spacer(),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.refresh),
                                  label: const Text(
                                    "Reload",
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
                        ),
                ),
              )
            ],
          ),
          if (loading)
            ModalBarrier(
              dismissible: false,
              color: Colors.black.withOpacity(0.2),
            ),
          if (loading)
            const Center(
              child: Text("Loading..."),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final passedData =
              await Navigator.pushNamed(context, "/duty_library");
          final result = passedData as Map?;
          if (result != null) {
            result["row_id"] = const Uuid().v4();
            final duty = buildDutyCardFromDuty(result);
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
