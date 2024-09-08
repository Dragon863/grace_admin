import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:grace_admin/pages/feed_page/feed_page_popup.dart';
import 'package:universal_io/io.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grace_admin/pages/feed_page/preview/preview.dart';
import 'package:grace_admin/utils/api.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  bool _loading = false;
  Icon deleteIcon = const Icon(Icons.delete, color: Colors.red);
  Icon attachTargetIcon = const Icon(Icons.attachment, color: Colors.black);
  List<String>? imageUrl;
  DateTime? expiryDate;
  Map buttonsMap = {};
  Icon addButtonIcon = const Icon(Icons.add);
  Text addButtonText = const Text("Add a Button");
  Text expiryDateText = const Text("Set expiry date");

  late Future<List<List<String>>> futureUrls;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController subtextController = TextEditingController();
  final previewFeedWidget = const PreviewFeed();

  Future<List<List<String>>> getAllImageUrls() async {
    List<List<String>> imageUrls = [];
    final api = context.read<AuthAPI>();
    final response = await api.client.storage.from("images").list(
          path: "events/",
          searchOptions: const SearchOptions(
            sortBy: SortBy(column: "created_at", order: "desc"),
          ),
        );
    for (final FileObject image in response) {
      final url = await api.client.storage
          .from("images")
          .getPublicUrl("events/${image.name}");
      imageUrls.add([url, image.name]);
    }
    return imageUrls;
  }

  Future<String?> uploadImage(String path) async {
    final api = context.read<AuthAPI>();
    final file = File(path);
    try {
      if (kIsWeb) {
        final Uint8List fileBytes = await file.readAsBytes();
        await api.client.storage
            .from("images")
            .uploadBinary('/events/${path.split('/').last}', fileBytes);
        return null;
      } else {
        await api.client.storage
            .from("images")
            .upload('/events/${path.split('/').last}', file);
        return null;
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> postToFeed() async {
    final api = context.read<AuthAPI>();
    final title = titleController.text;
    final subtext = subtextController.text;

    if (title.isEmpty || subtext.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill out all fields'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          width: 400,
        ),
      );
      return;
    }
    try {
      await api.client.from('events').insert([
        {
          'title': title,
          'subtext': subtext,
          'image': imageUrl?[1],
          'datecreated': DateTime.now().toIso8601String(),
          'buttons': buttonsMap,
          'dateexpired': expiryDate?.toIso8601String(),
        }
      ]);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Posted to feed successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          width: 400,
        ),
      );
      titleController.clear();
      subtextController.clear();
      imageUrl = null;
      setState(() {
        attachTargetIcon = const Icon(Icons.attachment, color: Colors.black);
      });
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error posting to feed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    futureUrls = getAllImageUrls();
    super.initState();
  }

  Future<void> reloadImages() async {
    setState(() {
      futureUrls = getAllImageUrls();
    });
  }

  void _showFeedPagePopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FeedPagePopup();
      },
    ).then((result) {
      if (result != null) {
        setState(() {
          buttonsMap = result;
          addButtonIcon = const Icon(Icons.add, color: Colors.green);
          addButtonText = const Text("Button added");
        });
      }
    });
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
                'Grace Admin Panel - Feed',
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
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
                border: Border(
              right: BorderSide(
                color: Color.fromARGB(255, 32, 109, 156),
                width: 2.0,
              ),
            )),
            child: const PreviewFeed(),
          ),
          Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.height * 0.6,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color.fromARGB(255, 32, 109, 156),
                      width: 2.0,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          SizedBox(
                            width: 350,
                            child: TextField(
                              controller: titleController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Post Title',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              DragTarget<List<String>>(
                                onAcceptWithDetails: (data) async {
                                  imageUrl = data.data;

                                  setState(() {
                                    attachTargetIcon = const Icon(
                                        Icons.attachment,
                                        color: Colors.green);
                                  });
                                },
                                onWillAcceptWithDetails: (details) {
                                  setState(() {
                                    attachTargetIcon = const Icon(Icons.add,
                                        color: Colors.green);
                                  });
                                  return true;
                                },
                                onLeave: (data) {
                                  setState(() {
                                    if (imageUrl == null) {
                                      attachTargetIcon = const Icon(
                                          Icons.attachment,
                                          color: Colors.black);
                                    } else {
                                      attachTargetIcon = const Icon(
                                          Icons.attachment,
                                          color: Colors.green);
                                    }
                                  });
                                },
                                builder:
                                    (context, candidateData, rejectedData) {
                                  // Delete area to drop images
                                  return Tooltip(
                                    message: 'Drag image here to attach',
                                    triggerMode: TooltipTriggerMode.tap,
                                    enableTapToDismiss: false,
                                    child: SizedBox(
                                      child: Container(
                                        height: 48,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          border: Border.all(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Row(
                                            children: [
                                              attachTargetIcon,
                                              const SizedBox(width: 8),
                                              imageUrl == null
                                                  ? const Text(
                                                      'Attach image',
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                      ),
                                                    )
                                                  : const Text(
                                                      'Image attached',
                                                      style: TextStyle(
                                                        color: Colors.green,
                                                      ),
                                                    ),
                                              const SizedBox(width: 8),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 4),
                              Visibility(
                                visible: imageUrl != null,
                                child: Tooltip(
                                  message: 'Remove attached image',
                                  child: IconButton(
                                    onPressed: () {
                                      imageUrl = null;
                                      setState(() {
                                        attachTargetIcon = const Icon(
                                            Icons.attachment,
                                            color: Colors.black);
                                      });
                                    },
                                    icon: const Icon(Icons.delete_forever,
                                        color: Colors.red),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: subtextController,
                        minLines: 3,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Post Subtext',
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              _showFeedPagePopup(context);
                            },
                            icon: addButtonIcon,
                            label: addButtonText,
                          ),
                          const SizedBox(width: 4),
                          OutlinedButton.icon(
                            onPressed: () async {
                              expiryDate = await showDatePicker(
                                context: context,
                                firstDate: DateTime(DateTime.now().year),
                                lastDate: DateTime(DateTime.now().year + 5),
                              );
                              if (expiryDate != null) {
                                setState(() {
                                  expiryDateText = const Text("Date set!");
                                });
                              }
                            },
                            icon: const Icon(Icons.calendar_today, size: 18),
                            label: expiryDateText,
                          ),
                          const SizedBox(width: 4),
                          Visibility(
                            visible: expiryDate != null,
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  expiryDate = null;
                                  expiryDateText =
                                      const Text("Set expiry date");
                                });
                              },
                              icon: const Icon(Icons.delete, color: Colors.red),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Visibility(
                            visible: buttonsMap.isNotEmpty,
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  addButtonText = const Text("Add a Button");
                                  addButtonIcon = const Icon(Icons.add);
                                  buttonsMap = {};
                                });
                              },
                              icon: const Icon(Icons.delete, color: Colors.red),
                            ),
                          ),
                          const SizedBox(width: 4),
                          FilledButton.icon(
                            onPressed: postToFeed,
                            icon: const Icon(Icons.send),
                            label: const Text('Post'),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Align(
                        alignment: Alignment.centerRight,
                        child: DragTarget<List<String>>(
                          onAcceptWithDetails: (data) async {
                            setState(() {
                              _loading = true;
                            });
                            final String name = data.data[1];
                            final api = context.read<AuthAPI>();
                            await api.client.storage
                                .from("images")
                                .remove(["events/$name"]);
                            reloadImages();
                            setState(() {
                              _loading = false;
                              deleteIcon =
                                  const Icon(Icons.delete, color: Colors.red);
                            });
                          },
                          onWillAcceptWithDetails: (details) {
                            setState(() {
                              deleteIcon = const Icon(Icons.delete_forever,
                                  color: Colors.red);
                            });
                            return true;
                          },
                          onLeave: (data) {
                            setState(() {
                              deleteIcon =
                                  const Icon(Icons.delete, color: Colors.red);
                            });
                          },
                          builder: (context, candidateData, rejectedData) {
                            // Delete area to drop images
                            return Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.red,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    deleteIcon,
                                    const SizedBox(width: 2),
                                    const Text(
                                      'Drag here to delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<List<List<String>>>(
                        future: futureUrls,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            _loading = true;
                            return const SizedBox();
                          }
                          _loading = false;

                          final urls = snapshot.data ?? [];
                          print(urls);
                          return Expanded(
                            child: GridView.builder(
                              physics: const ScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: urls.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                              ),
                              itemBuilder: (context, index) {
                                return LayoutBuilder(
                                  builder: (context, constraints) {
                                    return Draggable<List<String>>(
                                      data: urls[index],
                                      feedback: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Opacity(
                                          opacity: 0.5,
                                          child: Image.network(
                                            urls[index][0],
                                            fit: BoxFit.fitWidth,
                                            width: constraints.maxWidth,
                                          ),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Image.network(
                                          urls[index][0],
                                          fit: BoxFit.fitWidth,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          FilePickerResult? result = await FilePicker.platform.pickFiles();

          if (result != null) {
            File file = File(result.files.single.path!);
            setState(() {
              _loading = true;
            });
            final error = await uploadImage(file.path);
            if (error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error uploading image: $error'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.red,
                  width: 400,
                ),
              );
            }
            await reloadImages();
            setState(() {
              _loading = false;
            });
          }
        },
        label: const Text('Add image'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
