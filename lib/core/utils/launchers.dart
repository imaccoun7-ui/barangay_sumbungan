import 'package:url_launcher/url_launcher.dart';

/// Opens native phone and map applications from contact records.
class Launchers {
  Launchers._();

  /// Returns true when the dialer was opened. The resident still confirms the
  /// call inside the phone app before anything is dialled.
  static Future<bool> call(String number) async {
    final String cleaned = number.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleaned.isEmpty) return false;
    final Uri uri = Uri(scheme: 'tel', path: cleaned);
    try {
      if (await canLaunchUrl(uri)) {
        return launchUrl(uri);
      }
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  static Future<bool> openMap({
    required String label,
    double? latitude,
    double? longitude,
    String? address,
  }) async {
    final Uri uri;
    if (latitude != null && longitude != null && (latitude != 0 || longitude != 0)) {
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
      );
    } else {
      final String query = Uri.encodeComponent('$label ${address ?? ''}'.trim());
      uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    }
    try {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
