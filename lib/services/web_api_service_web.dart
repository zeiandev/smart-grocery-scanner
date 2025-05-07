
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:async';
import 'dart:convert';

class WebApiService {
  static Future<List<dynamic>> sendReceipt(Uint8List imageBytes) async {
    final uri = Uri.parse("https://smart-grocery-scanner.onrender.com/scan");

    final request = html.HttpRequest();
    request
      ..open('POST', uri.toString())
      ..setRequestHeader('Accept', 'application/json');

    final formData = html.FormData();
    final blob = html.Blob([imageBytes]);
    formData.appendBlob('file', blob, 'receipt.jpg');

    final completer = Completer<List<dynamic>>();
    bool isCompleted = false;

    request.onLoadEnd.listen((e) {
      if (isCompleted) return;
      isCompleted = true;

      print("📡 Request completed. Status: ${request.status}");
      print("📨 Raw response: ${request.responseText}");

      if (request.status == 200 && request.responseText != null) {
        try {
          final json = jsonDecode(request.responseText!);
          final items = json['items_detected'] ?? [];
          completer.complete(items);
        } catch (e) {
          print("❌ JSON parse error: \$e");
          completer.complete([]);
        }
      } else {
        print("🚫 Web upload failed with status: ${request.status}, response: ${request.responseText}");
        completer.complete([]);
      }
    });

    request.onError.listen((event) {
      if (isCompleted) return;
      isCompleted = true;

      print("🌐 Network or CORS error occurred during request.");
      completer.complete([]);
    });

    request.send(formData);
    return completer.future;
  }
}
