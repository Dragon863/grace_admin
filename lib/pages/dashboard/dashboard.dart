import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grace_admin/pages/dashboard/widgets/menu_item.dart';
import 'package:grace_admin/pages/dashboard/widgets/top_card.dart';
import 'package:grace_admin/utils/api.dart';
import 'package:provider/provider.dart';

class SquareDashTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Icon icon;
  final bool isSelected;

  const SquareDashTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: GoogleFonts.rubik(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.rubik(
          fontSize: 16,
        ),
      ),
      leading: CircleAvatar(
        child: icon,
      ),
      selected: isSelected,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
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
              width: 200,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  right: BorderSide(
                    color: Color.fromARGB(255, 32, 109, 156),
                    width: 1,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 72,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 70,
                        backgroundImage: AssetImage('assets/images/grace.png'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    DashMenuItem(
                      title: 'Dashboard',
                      iconData: Icons.dashboard_rounded,
                      onTap: () {
                        Navigator.pushNamed(context, '/home');
                      },
                      selected: true,
                    ),
                    DashMenuItem(
                      title: 'Users',
                      iconData: Icons.people_outline,
                      onTap: () {
                        Navigator.pushNamed(context, '/users');
                      },
                      selected: false,
                    ),
                    DashMenuItem(
                      title: 'Rotas',
                      iconData: Icons.work_outline,
                      onTap: () {
                        Navigator.pushNamed(context, '/rota_edit');
                      },
                      selected: false,
                    ),
                    DashMenuItem(
                      title: 'Feed',
                      iconData: Icons.format_list_bulleted,
                      onTap: () {
                        Navigator.pushNamed(context, '/feed');
                      },
                      selected: false,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Text(
                            'Welcome to Grace Admin Panel',
                            style: GoogleFonts.rubik(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'This is the admin panel for Grace, a duty management system for the NHS. '
                            'You can manage users, duties, and rota templates here.',
                            style: GoogleFonts.rubik(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TopCard(
                        title: 'Users',
                        subtitle: 'Manage users',
                        icon: Icon(Icons.people_outline),
                      ),
                      TopCard(
                        title: 'Duties',
                        subtitle: 'Manage duties',
                        icon: Icon(Icons.work_outline),
                      ),
                      TopCard(
                        title: 'Rota Templates',
                        subtitle: 'Manage rota templates',
                        icon: Icon(Icons.format_list_bulleted),
                      )
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            )
          ],
        ));
  }
}
