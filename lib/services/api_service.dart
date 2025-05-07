import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://smart-grocery-backend.onrender.com';

  static Future<List<dynamic>> sendReceipts(List<Uint8List> images) async {
    final uri = Uri.parse("$_baseUrl/scan");

    if (images.isEmpty) {
      print("🚫 No images provided.");
      return [];
    }

    final request = http.MultipartRequest('POST', uri);

    // Send only the first image — match Flask expectation
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      images[0],
      filename: 'receipt.jpg',
    ));

    print("📤 Uploading 1 image to API...");

    try {
      final response = await request.send();
      final result = await http.Response.fromStream(response);
      print("🛰️ Raw response: ${result.body}");

      if (result.statusCode == 200) {
        final data = jsonDecode(result.body);
        print("✅ Detected items:");
        for (var item in data['items_detected']) {
          print("   • ${item['item']} → ${item['days_left']} days left");
        }
        return data['items_detected'];
      } else {
        throw Exception("❌ Server error: ${result.body}");
      }
    } catch (e, stackTrace) {
      print("🚫 Exception: ${e.toString()}");
      print("🧱 Stack trace:\n$stackTrace");
      rethrow;
    }
  }
}
