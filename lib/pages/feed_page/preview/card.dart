import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grace_admin/pages/feed_page/preview/helpers/fullscreen_image.dart';
import 'package:url_launcher/url_launcher_string.dart';

class EventCard extends StatelessWidget {
  final String title;
  final String date;
  final String? subtext;
  final String? imageUrl;
  final String? url;

  const EventCard({
    super.key,
    required this.title,
    required this.date,
    this.imageUrl,
    this.subtext,
    this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            imageUrl != null
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.fullscreen),
                          color: Colors.black,
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) =>
                                    FullScreenImage(imageUrl: imageUrl!)));
                          },
                        ),
                      ),
                    ],
                  )
                : Container(),
            const SizedBox(height: 10),
            Row(
              children: [
                SelectableText(
                  title,
                  style: GoogleFonts.rubik(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                SelectableText(
                  date,
                  style: GoogleFonts.rubik(
                    fontSize: 12,
                  ),
                )
              ],
            ),
            const SizedBox(height: 5),
            subtext == null
                ? Container()
                : Row(
                    children: [
                      Linkify(
                        text: subtext!,
                        onOpen: (link) async {
                          if (await canLaunchUrlString(link.url)) {
                            await launchUrlString(link.url);
                          } else {
                            throw 'Could not launch $link';
                          }
                        },
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
