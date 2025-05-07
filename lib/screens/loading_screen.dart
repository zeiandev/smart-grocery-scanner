import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../services/web_api_service.dart';

const Color kPrimaryGreen = Color(0xFF4CAF50);
const Color kBackground = Color(0xFFF9FDF9);
const Color kTextSecondary = Color(0xFF757575);

class LoadingScreen extends StatefulWidget {
  final List<Uint8List> images;

  const LoadingScreen({super.key, required this.images});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _process();
  }

  Future<void> _process() async {
    try {
      dynamic results;

      if (kIsWeb) {
        await WebApiService.sendReceipt(widget.images.first);
        results = []; // You can parse actual response later if needed
      } else {
        results = await ApiService.sendReceipts(widget.images);
      }

      Navigator.pop(context, results);
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: kBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: kPrimaryGreen,
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Scanning receipt...",
              style: TextStyle(fontSize: 16, color: kTextSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
