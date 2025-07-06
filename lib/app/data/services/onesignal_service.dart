import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OneSignalService {
  static final String _restApiKey = dotenv.env['ONESIGNAL_REST_API_KEY']!;
  static final String _appId = dotenv.env['ONESIGNAL_APP_ID']!;

  /// Mengirim notifikasi ke user berdasarkan OneSignal playerId (device id)
  static Future<void> sendNotification({
    required String playerId,
    required String title,
    required String message,
  }) async {
    const String url = 'https://onesignal.com/api/v1/notifications';

    final body = {
      "app_id": _appId,
      "include_player_ids": [playerId],
      "headings": {"en": title},
      "contents": {"en": message},
    };

    final headers = {
      "Content-Type": "application/json; charset=utf-8",
      "Authorization": "Basic $_restApiKey",
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('✅ Notifikasi berhasil dikirim ke playerId: $playerId');
      } else {
        print('❌ Gagal mengirim notifikasi. Status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('❌ Error mengirim notifikasi: $e');
    }
  }
}
