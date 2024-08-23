import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:grace_admin/pages/feed_page/preview/card.dart';
import 'package:grace_admin/utils/api.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PreviewFeed extends StatefulWidget {
  const PreviewFeed({super.key});

  @override
  State<PreviewFeed> createState() => _PreviewFeedState();
}

class _PreviewFeedState extends State<PreviewFeed> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>>? content;

  Future<List<Map<String, dynamic>>> fetchEvents(bool refresh) async {
    if (content == null || refresh) {
      final response = await supabase.from('events').select();
      content = response;
      return response.reversed.toList();
    } else {
      return content!.reversed.toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            content = null;
          });
          await fetchEvents(true);
        },
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchEvents(false),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('No events found');
            } else {
              return Container(
                constraints: const BoxConstraints(minWidth: 150, maxWidth: 700),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final event = snapshot.data![index];
                    String? imageUrl;
                    if (event['image'] != null) {
                      final api = context.read<AuthAPI>();
                      imageUrl = api.getImgUrl(event['image'], 'events');
                    }
                    return EventCard(
                      title: event['title'],
                      subtext: event['subtext'],
                      date:
                          event['datecreated'].toString().replaceAll("-", "."),
                      imageUrl: imageUrl,
                      onDelete: () async {
                        await supabase
                            .from('events')
                            .delete()
                            .eq('id', event['id']);
                        setState(() {
                          content = null;
                        });
                      },
                      buttons: event['buttons'],
                    );
                  },
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
