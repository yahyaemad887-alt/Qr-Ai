import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/history_service.dart';
import '../models/qr_item.dart';
import '../core/app_localizations.dart';

class QrImageScreen extends StatefulWidget {
  final String data;

  const QrImageScreen({super.key, required this.data});

  @override
  State<QrImageScreen> createState() => _QrImageScreenState();
}

class _QrImageScreenState extends State<QrImageScreen> {
  @override
  void initState() {
    super.initState();
    _saveToHistory();
  }

  Future<void> _saveToHistory() async {
    final newItem = QRItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      data: widget.data,
      type: 'Generated',
      timestamp: DateTime.now(),
    );
    await HistoryService.saveHistory(newItem);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('generated_qr_title')),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white, // خلفية بيضاء ثابتة لضمان وضوح فحص الـ QR
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: QrImageView(
                  data: widget.data,
                  version: QrVersions.auto,
                  size: 220.0,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              SelectableText(
                widget.data,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              Text(
                loc.translate('saved_to_history_success'),
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}