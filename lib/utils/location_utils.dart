import 'package:url_launcher/url_launcher.dart';

class LocationUtils {
  static Future<void> openInGoogleMaps(
    double latitude,
    double longitude,
  ) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    // Use url_launcher package to open the URL
    // Make sure to add url_launcher to your pubspec.yaml
    // import 'package:url_launcher/url_launcher.dart';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch Google Maps';
    }
  }

  static Future<String> getGoogleMapsUrl(
    double latitude,
    double longitude,
  ) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    return url;
  }
}
