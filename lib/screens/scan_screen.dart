import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/history_service.dart';
import '../models/qr_item.dart';
import '../core/app_localizations.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _isScanning = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // التقاط صورة QR من المعرض
  Future<void> _pickImageFromGallery(AppLocalizations loc) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final BarcodeCapture? capture = await _controller.analyzeImage(image.path);
      if (capture != null && capture.barcodes.isNotEmpty) {
        final String? code = capture.barcodes.first.rawValue;
        if (code != null) {
          _handleBarcodeResult(code, loc);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loc.translate('no_qr_found_in_image'))),
          );
        }
      }
    }
  }

  // التعامل مع النتيجة (إظهار النتيجة في BottomSheet وحفظها في السجل)
  Future<void> _handleBarcodeResult(String code, AppLocalizations loc) async {
    if (!_isScanning) return;
    setState(() => _isScanning = false);

    // حفظ الكود المُلتتقط تلقائياً في السجل
    final newItem = QRItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      data: code,
      type: 'Scanned',
      timestamp: DateTime.now(),
    );
    await HistoryService.addItem(newItem);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loc.translate('scan_result_title'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SelectableText(
                  code,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: code));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(loc.translate('text_copied_snack'))),
                        );
                      },
                      icon: const Icon(Icons.copy),
                      label: Text(loc.translate('copy_button')),
                    ),
                  ),
                  if (Uri.tryParse(code)?.hasAbsolutePath ?? false) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final Uri url = Uri.parse(code);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          }
                        },
                        icon: const Icon(Icons.open_in_browser),
                        label: Text(loc.translate('open_link_button')),
                      ),
                    ),
                  ]
                ],
              ),
            ],
          ),
        );
      },
    ).then((_) {
      if (mounted) {
        setState(() => _isScanning = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          // عرض الكاميرا والفحص
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _handleBarcodeResult(barcode.rawValue!, loc);
                  break;
                }
              }
            },
          ),

          // أزرار التحكم العلوي (الفلاش والمعرض في اليسار لمنع التداخل مع الإعدادات)
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // زر الفلاش
                    ValueListenableBuilder(
                      valueListenable: _controller,
                      builder: (context, state, child) {
                        return CircleAvatar(
                          backgroundColor: Colors.black45,
                          child: IconButton(
                            icon: Icon(
                              state.torchState == TorchState.on
                                  ? Icons.flash_on
                                  : Icons.flash_off,
                              color: Colors.white,
                            ),
                            onPressed: () => _controller.toggleTorch(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    // زر الاستوديو
                    CircleAvatar(
                      backgroundColor: Colors.black45,
                      child: IconButton(
                        icon: const Icon(Icons.image, color: Colors.white),
                        onPressed: () => _pickImageFromGallery(loc),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}