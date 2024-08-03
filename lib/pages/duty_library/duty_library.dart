import 'package:flutter/material.dart';
import 'package:grace_admin/pages/duty_library/duty_library_controller.dart';
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
        leading: const CircleAvatar(
          child: Icon(Icons.refresh),
        ))
  ];
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

  @override
  void initState() {
    _onSearchChanged("");
    super.initState();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final widgetResults = await searchDuties(query, context.read<AuthAPI>());
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
            'Grace Admin Panel - Duty Library',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                  const Text(
                    "Create New Duty",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Color.fromARGB(255, 32, 109, 156),
                    ),
                  ),
                  SizedBox(height: 4),
                  const TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Duty Title',
                    ),
                  ),
                  const SizedBox(height: 12),
                  const TextField(
                    minLines: 3,
                    maxLines: 3,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Duty Description',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.schedule),
                      label: const Text("Pick Time"),
                    ),
                    const Spacer(),
                  ]),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: FloatingActionButton.extended(
                      onPressed: () {},
                      label: Text("Save"),
                      icon: Icon(Icons.save),
                    ),
                  )
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
