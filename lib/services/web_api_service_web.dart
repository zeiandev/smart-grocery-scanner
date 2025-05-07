import 'dart:html' as html;
import 'dart:typed_data';

class WebApiService {
  static Future<void> sendReceipt(Uint8List imageBytes) async {
    final uri = Uri.parse("https://smart-grocery-scanner.onrender.com/scan");

    final request = html.HttpRequest();
    request.open('POST', uri.toString());
    request.setRequestHeader('Accept', 'application/json');

    final formData = html.FormData();
    final blob = html.Blob([imageBytes]);
    formData.appendBlob('file', blob, 'receipt.jpg');

    request.onLoadEnd.listen((e) {
      if (request.status == 200) {
        print("✅ Web upload response: \${request.responseText}");
      } else {
        print("🚫 Web upload failed with status: \${request.status}");
      }
    });

    request.send(formData);
  }
}
