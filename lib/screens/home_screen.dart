
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../services/web_api_service.dart';
import 'receipt_preview_screen.dart';
import 'loading_screen.dart';
import 'result_screen.dart';

const Color kPrimaryGreen = Color(0xFF4CAF50);
const Color kLightGreen = Color(0xFFA5D6A7);
const Color kBackground = Color(0xFFF9FDF9);
const Color kTextPrimary = Color(0xFF212121);
const Color kTextSecondary = Color(0xFF757575);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _showUploadOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt, color: kPrimaryGreen),
            title: const Text("Take Photo"),
            onTap: () => _pickImage(ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo, color: kPrimaryGreen),
            title: const Text("Upload from Gallery"),
            onTap: () => _pickImage(ImageSource.gallery),
          ),
          ListTile(
            leading: const Icon(Icons.edit, color: kPrimaryGreen),
            title: const Text("Manual Entry"),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Manual entry not implemented")),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context);
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    final confirmed = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReceiptPreviewScreen(initialImages: [bytes]),
      ),
    );

    if (confirmed == null || confirmed.isEmpty) return;

    dynamic results;
    if (kIsWeb) {
      await WebApiService.sendReceipt(confirmed.first);
      results = [];
    } else {
      results = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => LoadingScreen(images: confirmed)),
      );
    }

    if (results != null && results.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResultScreen(items: results)),
      );
    }
  }

  Widget loadProductIcon(String sku) {
    final extensions = ['png', 'jpg', 'webp'];
    for (final ext in extensions) {
      final path = 'assets/product_icons/$sku.$ext';
      try {
        return Image.asset(
          path,
          width: 40,
          errorBuilder: (_, __, ___) => const Icon(Icons.inventory, color: kPrimaryGreen),
        );
      } catch (_) {}
    }
    return const Icon(Icons.inventory, color: kPrimaryGreen);
  }

  Widget _buildItemCard(dynamic item) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: loadProductIcon(item['sku']),
        title: Text(item['item'],
            style: const TextStyle(fontWeight: FontWeight.w500, color: kTextPrimary)),
        subtitle: Text("${item['days_left']} days left",
            style: const TextStyle(color: kTextSecondary)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text(
          "Smart Grocery Scanner",
          style: TextStyle(fontWeight: FontWeight.bold, color: kTextPrimary),
        ),
        centerTitle: true,
        backgroundColor: kBackground,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: kPrimaryGreen),
      ),
      body: const Center(
        child: Text(
          "No items yet.\nTap + to scan a receipt",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: kTextSecondary),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showUploadOptions,
        elevation: 4,
        backgroundColor: kPrimaryGreen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
    );
  }
}
