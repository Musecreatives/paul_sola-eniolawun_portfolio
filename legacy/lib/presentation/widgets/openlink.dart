import 'package:url_launcher/url_launcher.dart';

Future<void> openLink(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    // handle error, e.g. show a Snackbar
  }
}
