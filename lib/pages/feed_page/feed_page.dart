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

  Future<List<String>> getAllImageUrls() async {
    List<String> imageUrls = [];
    final api = context.read<AuthAPI>();
    final response = await api.client.storage.from("images").list(
          path: "events",
          searchOptions: const SearchOptions(
            sortBy: SortBy(column: "created_at", order: "asc"),
          ),
        );
    for (final FileObject image in response) {
      final url = await api.client.storage
          .from("images")
          .createSignedUrl(image.toString(), 60);
      imageUrls.add(url);
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
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Text(
                    "Feed Preview",
                    style: GoogleFonts.rubik(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: const Color.fromARGB(255, 32, 109, 156),
                    ),
                  ),
                  const PreviewFeed(),
                ],
              ),
            ),
          ),
          Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.height * 0.4,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: const Color.fromARGB(255, 32, 109, 156),
                      width: 2.0,
                    ),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      SizedBox(
                        width: 350,
                        child: TextField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Post Title',
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        minLines: 3,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Post Subtext',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Show all images from getAllImageUrls in a grid
              FutureBuilder<List<String>>(
                future: getAllImageUrls(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final urls = snapshot.data ?? [];
                  return Expanded(
                    child: GridView.builder(
                      shrinkWrap: true,
                      itemCount: urls.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                      ),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.network(urls[index]),
                        );
                      },
                    ),
                  );
                },
              )
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {},
        label: const Text('Add Post'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
