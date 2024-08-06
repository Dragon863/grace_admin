import 'package:flutter/material.dart';
import 'package:grace_admin/pages/duty_library/duty_library_controller.dart';
import 'package:grace_admin/pages/duty_library/widgets/duty_tile.dart';
import 'package:grace_admin/utils/api.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class DutyLibraryPage extends StatefulWidget {
  const DutyLibraryPage({super.key});

  @override
  State<DutyLibraryPage> createState() => _DutyLibraryPageState();
}

class _DutyLibraryPageState extends State<DutyLibraryPage> {
  List<Widget> searchResults = [
    const ListTile(
        title: Text("Loading..."),
        leading: CircleAvatar(
          child: Icon(Icons.refresh),
        ))
  ];
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  TimeOfDay _time = TimeOfDay.now();
  String _selectedDutyId = "";
  String _leftPanelTitle = "Create New Duty";
  bool _loading = false;

  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    _onSearchChanged("");
    super.initState();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    setState(() {
      _loading = true;
    });
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final api = context.read<AuthAPI>();
      final duties = await api.client.from("duties").select();
      // Example data: [[User's Name, ffffffff-ffff-ffff-ffff-ffffffffffff]]
      List matchingDuties;

      if (query.isNotEmpty) {
        matchingDuties = duties
            .where((user) =>
                user["title"].toLowerCase().contains(query.toLowerCase()))
            .toList();
      } else {
        matchingDuties = duties;
      }
      final widgetResults = matchingDuties
          .map(
            (duty) => DutyTile(
              duty: duty,
              onAdd: () {
                Navigator.pop(context, duty);
              },
              onEdit: () {
                editDuty(duty);
                _selectedDutyId = duty["id"];
              },
              onDeleteStart: () {
                setState(() {
                  _loading = true;
                });
              },
              onDeleteEnd: () {
                _onSearchChanged("");
              },
            ),
          )
          .toList();
      setState(() {
        searchResults = widgetResults;
        _loading = false;
      });
    });
  }

  void editDuty(Map duty) async {
    setState(() {
      _titleController.text = duty["title"];
      _descriptionController.text = duty["description"] ?? "";
      // Time is a string in format HH:MM:SS
      _time = TimeOfDay(
        hour: int.parse(duty["time"].split(":")[0]),
        minute: int.parse(duty["time"].split(":")[1]),
      );
      setState(() {
        _leftPanelTitle = """Editing "${duty['title']}" """;
      });
    });
  }

  void newFABPressed() {
    _titleController.clear();
    _descriptionController.clear();
    setState(() {
      _leftPanelTitle = "Create New Duty";
    });
    _selectedDutyId = "";
    _time = TimeOfDay.now();
  }

  void saveFABPressed() async {
    setState(() {
      _loading = true;
    });
    final api = context.read<AuthAPI>();
    final data = {
      "title": _titleController.text,
      "description": _descriptionController.text,
      "time": "${_time.hour}:${_time.minute}:00",
    };
    if (_selectedDutyId.isEmpty) {
      await api.client.from("duties").insert(data);
    } else {
      await api.client.from("duties").update(data).eq("id", _selectedDutyId);
    }
    _onSearchChanged("");
    setState(() {
      _loading = false;
    });
    newFABPressed();
  }

  void refreshData() {
    _onSearchChanged("");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Visibility(
                visible: _loading,
                child: const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Grace Admin Panel - Duty Library',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 32, 109, 156),
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: true,
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
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Text(
                    _leftPanelTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Color.fromARGB(255, 32, 109, 156),
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Duty Title',
                    ),
                    controller: _titleController,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    minLines: 3,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Duty Description',
                    ),
                    controller: _descriptionController,
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        showTimePicker(
                          context: context,
                          initialTime: _time,
                        ).then((value) {
                          if (value != null) {
                            setState(() {
                              _time = value;
                            });
                          }
                        });
                      },
                      icon: const Icon(Icons.schedule),
                      label: Text(
                          "${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}"),
                    ),
                    const Spacer(),
                  ]),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FloatingActionButton.extended(
                          onPressed: newFABPressed,
                          label: const Text("New"),
                          icon: const Icon(Icons.add),
                          heroTag: "new",
                        ),
                        const SizedBox(width: 8),
                        FloatingActionButton.extended(
                          onPressed: saveFABPressed,
                          label: const Text("Save"),
                          icon: const Icon(Icons.save),
                          heroTag: "save",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.7,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SearchBar(
                    hintText: "Search Duties",
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    padding: WidgetStateProperty.all<EdgeInsets>(
                        const EdgeInsets.symmetric(horizontal: 15)),
                    leading: const Icon(Icons.search),
                    shadowColor: WidgetStateColor.transparent,
                    onChanged: _onSearchChanged,
                    autoFocus: true,
                  ),
                  const SizedBox(height: 5),
                  Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      children: searchResults,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
