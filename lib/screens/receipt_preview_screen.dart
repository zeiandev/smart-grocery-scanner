import 'dart:typed_data';
import 'package:flutter/material.dart';

const Color kPrimaryGreen = Color(0xFF4CAF50);
const Color kBackground = Color(0xFFF9FDF9);

class ReceiptPreviewScreen extends StatelessWidget {
  final List<Uint8List> initialImages;
  const ReceiptPreviewScreen({super.key, required this.initialImages});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kBackground,
        elevation: 0.5,
        title: const Text("Confirm Receipt", style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: kPrimaryGreen),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: initialImages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(initialImages[index]),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => Navigator.pop(context, initialImages),
                child: const Text("Register", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          )
        ],
      ),
    );
  }
}
