import 'package:flutter/material.dart';
import 'package:grace_admin/utils/api.dart';
import 'package:provider/provider.dart';

class RotaEditPageNew extends StatefulWidget {
  const RotaEditPageNew({super.key});

  @override
  State<RotaEditPageNew> createState() => _RotaEditPageNewState();
}

class _RotaEditPageNewState extends State<RotaEditPageNew> {
  AuthAPI? api;

  @override
  void initState() {
    final inheritedApi = context.read<AuthAPI>();
    api = inheritedApi;
    /*inheritedApi.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session == null) {
        Navigator.of(context).pushReplacementNamed('/splash');
      }
    });*/
    super.initState();
  }

  Future<List<Map>> fetchWeeks() async {
    final response = await api!.client
        .from('weeks')
        .select('*, months(name), roles(*)')
        .order('date');
    for (var week in response) {
      week['months'] = await api!.client
          .from("months")
          .select("*")
          .eq("id", week['month_id'])
          .single();
    }
    return List<Map>.from(response as List).reversed.toList(); 
  }

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
      body: FutureBuilder<List<Map>>(
        future: fetchWeeks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final weeksData = snapshot.data ?? [];
          final groupedByMonth = <String, List<Map>>{};

          for (var week in weeksData) {
            final monthName = week['months']['name'];
            if (!groupedByMonth.containsKey(monthName)) {
              groupedByMonth[monthName] = [];
            }
            groupedByMonth[monthName]!.add(week);
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: groupedByMonth.entries.map((entry) {
                  final monthName = entry.key;
                  final weeks = entry.value;

                  return buildMonthSection(
                    monthName,
                    weeks.map((week) {
                      print(week);
                      final roles = (week['roles'] as List).map((role) {
                        final user = role['profiles'];
                        return Person(user['name'], role['role'], false);
                        // role['is_unavailable']);
                      }).toList();

                      return buildWeekCard(
                        week['week_number'],
                        week['date'],
                        week['description'],
                        week['time'],
                        roles,
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildMonthSection(String month, List<Widget> weekCards) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  month,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  // Handle adding a new week for this month
                },
              ),
            ],
          ),
          Column(
            children: weekCards,
          ),
        ],
      ),
    );
  }

  Widget buildWeekCard(String week, String date, String description,
      String time, List<Person> people) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$week',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              date,
              style: TextStyle(fontSize: 16, color: Colors.blue),
            ),
            Text(
              time,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Divider(),
            Text(description),
            Divider(),
            ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children:
                    people.map((person) => buildPersonRow(person)).toList()),
            Center(
              child: ListTile(
                onTap: () async {},
                title: const Text('Add Role',
                    style: TextStyle(color: Colors.blue)),
                leading: const Icon(Icons.add, color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPersonRow(Person person) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: person.isUnavailable ? Colors.red : Colors.blue,
            child: Icon(person.isUnavailable ? Icons.close : Icons.person),
          ),
          const SizedBox(width: 8),
          Text(
            person.name,
            style: TextStyle(
              decoration: person.isUnavailable
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
          const Spacer(),
          Text(person.role),
        ],
      ),
    );
  }
}

class Person {
  final String name;
  final String role;
  final bool isUnavailable;

  Person(this.name, this.role, [this.isUnavailable = false]);
}

/*
ListTile(
  onTap: () async {},
  title: const Text('Log Out',
      style: TextStyle(color: Colors.red)),
  leading: const Icon(Icons.logout, color: Colors.red),
),
*/