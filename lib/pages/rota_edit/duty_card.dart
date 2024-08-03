import 'package:flutter/material.dart';

class DutyCard extends StatefulWidget {
  final String title;
  final String description;
  final DateTime time;

  const DutyCard({
    super.key,
    required this.title,
    required this.description,
    required this.time,
  });

  @override
  State<DutyCard> createState() => _DutyCardState();
}

class _DutyCardState extends State<DutyCard> {
  List<String> acceptedUser = [];
  var isDragging = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "${widget.time.hour}:${widget.time.minute}",
                  style: const TextStyle(fontSize: 16, color: Colors.blue),
                ),
                Text(widget.description),
                const Divider(),
                DragTarget<List<String>>(
                  builder: (
                    BuildContext context,
                    List<dynamic> accepted,
                    List<dynamic> rejected,
                  ) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: acceptedUser.isNotEmpty
                            ? null
                            : Colors.red.shade200,
                        child: acceptedUser.isNotEmpty
                            ? const Icon(Icons.person)
                            : const Icon(Icons.person_search),
                      ),
                      title: Text(acceptedUser.isNotEmpty
                          ? acceptedUser[0]
                          : 'None Selected'),
                      trailing: acceptedUser.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  acceptedUser = [];
                                  isDragging = false;
                                });
                              },
                            )
                          : isDragging
                              ? const Icon(Icons.add)
                              : null,
                    );
                  },
                  onAcceptWithDetails: (details) {
                    setState(() {
                      acceptedUser = details.data;
                    });
                  },
                  onWillAcceptWithDetails: (data) {
                    setState(() {
                      isDragging = true;
                    });
                    return true;
                  },
                  onLeave: (data) {
                    setState(() {
                      isDragging = false;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<String> get accepted => acceptedUser;
}
