
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'http://127.0.0.1:5000'; // make sure this is updated
  // static const String _baseUrl = 'http://127.0.0.1:5000';
  static Future<List<dynamic>> sendReceipts(List<Uint8List> images) async {
    final uri = Uri.parse("$_baseUrl/scan"); //
    final request = http.MultipartRequest('POST', uri);

    for (int i = 0; i < images.length; i++) {
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        images[i],
        filename: 'receipt_$i.jpg',
      ));
    }

    print("📤 Uploading \${images.length} image(s) to API...");

    try {
      final response = await request.send();
      final result = await http.Response.fromStream(response);
      print("🛰️ Raw response: \${result.body}");

      if (result.statusCode == 200) {
        final data = jsonDecode(result.body);
        print("✅ Detected items:");
        for (var item in data['items_detected']) {
          print("   • ${item['item']} → ${item['days_left']} days left");
        }
        return data['items_detected'];
      } else {
        throw Exception("❌ Server error: \${result.body}");
      }
    } catch (e) {
      print("🚫 Exception in sendReceipts: \$e");
      print("🧱 Stack trace:\n\$stack");
      rethrow;
    }
  }
}
