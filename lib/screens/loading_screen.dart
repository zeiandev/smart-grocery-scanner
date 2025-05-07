import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

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
      final results = await ApiService.sendReceipts(widget.images);
      Navigator.pop(context, results); // ✅ Return results to HomeScreen
    } catch (e) {
      Navigator.pop(context); // Even if error, go back safely
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
              "Scanning your receipt...",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: kTextSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
