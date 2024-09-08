// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class DutyCard extends StatefulWidget {
  final String title;
  final String description;
  final DateTime time;
  final Function onRemovePressed;
  final String id;
  final String? row_id;
  List<String>? acceptedUser;

  DutyCard({
    super.key,
    required this.title,
    required this.description,
    required this.time,
    required this.onRemovePressed,
    required this.id,
    required this.row_id,
    this.acceptedUser,
  });

  @override
  State<DutyCard> createState() => _DutyCardState();
}

class _DutyCardState extends State<DutyCard> {
  List<String> acceptedUser = [];
  var isDragging = false;

  @override
  void initState() {
    super.initState();
    if (widget.acceptedUser != null) {
      acceptedUser = widget.acceptedUser!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    DateFormat('HH:mm').format(widget.time),
                    // *Not* "HH:MM". I spent far too long debugging that.
                    style: const TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ]),
                const Spacer(),
                IconButton(
                  splashRadius: 25,
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: widget.onRemovePressed as void Function(),
                ),
              ]),
              Flexible(
                  child: Text(
                widget.description,
                softWrap: true,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )),
              const Divider(),
              DragTarget<List<String>>(
                builder: (
                  BuildContext context,
                  List<dynamic> accepted,
                  List<dynamic> rejected,
                ) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          acceptedUser.isNotEmpty ? null : Colors.red.shade200,
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
                    widget.acceptedUser = acceptedUser;
                    print(acceptedUser);
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
    );
  }

  List<String> get accepted => acceptedUser;
}
