import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grace_admin/utils/api.dart';
import 'package:provider/provider.dart';
import 'package:grace_admin/pages/users_page/users_page_controller.dart';
import 'dart:async';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  List<Widget> searchResults = [
    const ListTile(
        title: Text("Loading..."),
        leading: CircleAvatar(
          child: Icon(Icons.refresh),
        ))
  ];
  final TextEditingController _searchController = TextEditingController();
  bool _loading = false;
  int _totalUsers = 0;
  int _onboardedUsers = 0;

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
    _loadStatistics();
    super.initState();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _loading = true;
    });
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final widgetResults =
          await searchUsers(query, context.read<AuthAPI>(), context);
      setState(() {
        searchResults = widgetResults;
        _loading = false;
      });
    });
  }

  void _loadStatistics() async {
    final api = context.read<AuthAPI>();
    final users = await api.getAllUsers();
    final onboardedUsers = users.where((user) => user[1] != "").toList();
    setState(() {
      // Subtract 1 to account for the admin service account
      _totalUsers = users.length - 1;
      _onboardedUsers = onboardedUsers.length - 1;
    });
  }

  void refreshData() {
    _onSearchChanged("");
    _loadStatistics();
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
              Text(
                'Grace Admin Panel - User Management',
                style: GoogleFonts.rubik(
                    color: Colors.white, fontWeight: FontWeight.bold),
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
                    "User Statistics",
                    style: GoogleFonts.rubik(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: const Color.fromARGB(255, 32, 109, 156),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              "Total Users",
                              style: GoogleFonts.rubik(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _totalUsers.toString(),
                              style: GoogleFonts.rubik(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: const Color.fromARGB(255, 32, 109, 156),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              "Onboarded Users",
                              style: GoogleFonts.rubik(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _onboardedUsers.toString(),
                              style: GoogleFonts.rubik(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: const Color.fromARGB(255, 32, 109, 156),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: refreshData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 32, 109, 156),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: const Text("Refresh Data"),
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
                    hintText: "Search Users",
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
