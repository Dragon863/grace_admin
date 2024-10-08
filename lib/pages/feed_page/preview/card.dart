import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grace_admin/pages/feed_page/preview/helpers/fullscreen_image.dart';
import 'package:grace_admin/pages/login/color_helper.dart';
import 'package:url_launcher/url_launcher_string.dart';

class EventCard extends StatelessWidget {
  final String title;
  final String date;
  final String? subtext;
  final String? imageUrl;
  final String? url;
  final Map? buttons;
  final void Function()? onDelete;

  const EventCard({
    super.key,
    required this.title,
    required this.date,
    this.imageUrl,
    this.subtext,
    this.url,
    this.buttons,
    this.onDelete,
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: SelectableText(
                    title,
                    style: GoogleFonts.rubik(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SelectableText(
                  date,
                  style: GoogleFonts.rubik(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            if (subtext == null)
              Container()
            else
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
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete),
              ),
            ),
            if ((buttons ?? {}).isNotEmpty)
              Align(
                alignment: Alignment.bottomLeft,
                child: FilledButton(
                  onPressed: () async {
                    await launchUrlString(buttons!["url"]);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: getColorFromDbString(buttons?["color"]),
                  ),
                  child: Text(buttons?["text"]),
                ),
              )
            else
              const SizedBox()
          ],
        ),
      ),
    );
  }
}
