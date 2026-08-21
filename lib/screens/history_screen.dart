import 'package:flutter/material.dart';
import '../services/history_service.dart';
import '../models/qr_item.dart';
import '../core/app_localizations.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  Future<void> _clearAll(AppLocalizations loc) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.translate('clear_history_dialog_title')),
        content: Text(loc.translate('clear_history_dialog_msg')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.translate('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              loc.translate('clear_all'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await HistoryService.clearHistory();
      setState(() {});
    }
  }

  String _getTranslatedType(String type, AppLocalizations loc) {
    if (type.toLowerCase() == 'scanned') {
      return loc.translate('type_scanned');
    } else if (type.toLowerCase() == 'generated') {
      return loc.translate('type_generated');
    }
    return type;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final currentTextDir = Directionality.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            children: [
              // زر مسح السجل مثبت على اليسار لمنع التداخل مع الإعدادات
              IconButton(
                icon: const Icon(Icons.delete_sweep),
                tooltip: loc.translate('clear_all'),
                onPressed: () => _clearAll(loc),
              ),
              Expanded(
                child: Directionality(
                  textDirection: currentTextDir,
                  child: Text(
                    loc.translate('history_title'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 48), // مساحة تعويضية لتوازن العنوان مع زر الإعدادات
            ],
          ),
        ),
      ),
      body: FutureBuilder<List<QRItem>>(
        future: HistoryService.getHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                '${loc.translate('error_occurred')}${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    loc.translate('no_history_found'),
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: items.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                child: ListTile(
                  leading: Icon(
                    Icons.qr_code,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text(
                    item.data,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    _getTranslatedType(item.type, loc),
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () async {
                      await HistoryService.removeItemAt(index);
                      setState(() {});
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}