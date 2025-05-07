
import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final List<dynamic> items;
  const ResultScreen({super.key, required this.items});

  Widget loadProductIcon(String rawSku) {
  final sku = rawSku.toLowerCase();
  final extensions = ['png', 'jpg', 'webp'];

  return Builder(
    builder: (_) {
      for (final ext in extensions) {
        final path = 'assets/product_icons/$sku.$ext';
        return Image.asset(
          path,
          width: 40,
          errorBuilder: (_, __, ___) {
            print('❌ Failed to load asset: $path');
            return const Icon(Icons.inventory, color: Colors.red);
          },
        );
      }
      return const Icon(Icons.inventory, color: Colors.red);
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Detected Items")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (_, index) {
                final item = items[index];
                return Card(
                  child: ListTile(
                    leading: loadProductIcon(item['sku']),
                    title: Text(item['item']),
                    subtitle: Text("${item['days_left']} days left"),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.green),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                    child: const Text("Go Back", style: TextStyle(color: Colors.green)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Upload Again", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
