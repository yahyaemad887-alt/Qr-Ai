import 'package:flutter/material.dart';
import 'scan_screen.dart';
import 'generate_screen.dart';
import 'history_screen.dart';
import '../core/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  final Function(Locale) onLocaleChanged;
  final Function(ThemeMode) onThemeModeChanged;
  final ThemeMode currentThemeMode;

  const HomeScreen({
    super.key,
    required this.onLocaleChanged,
    required this.onThemeModeChanged,
    required this.currentThemeMode,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    ScanScreen(),
    GenerateScreen(),
    HistoryScreen(),
  ];

  // خريطة اللغات المدعومة بأسماء واضحة
  final Map<String, String> _languages = {
    'ar': 'العربية',
    'en': 'English',
    'es': 'Español',
    'fr': 'Français',
    'de': 'Deutsch',
    'ru': 'Русский',
    'pt': 'Português',
  };

  void _showSettingsBottomSheet(BuildContext context, AppLocalizations loc) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setBottomSheetState) {
            final currentLangCode = Localizations.localeOf(context).languageCode;

            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          loc.translate('settings_title'),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 10),

                    // اختيار اللغة
                    Text(
                      loc.translate('language'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _languages.containsKey(currentLangCode)
                          ? currentLangCode
                          : 'en',
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: _languages.entries.map((entry) {
                        return DropdownMenuItem<String>(
                          value: entry.key,
                          child: Text(entry.value),
                        );
                      }).toList(),
                      onChanged: (String? newLangCode) {
                        if (newLangCode != null) {
                          widget.onLocaleChanged(Locale(newLangCode));
                          Navigator.pop(context);
                        }
                      },
                    ),

                    const SizedBox(height: 20),

                    // اختيار الثيم (الوضع الداكن/الفاتح)
                    Text(
                      loc.translate('theme'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<ThemeMode>(
                      segments: [
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.light,
                          label: Text(loc.translate('light_mode')),
                          icon: const Icon(Icons.light_mode),
                        ),
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.dark,
                          label: Text(loc.translate('dark_mode')),
                          icon: const Icon(Icons.dark_mode),
                        ),
                      ],
                      selected: {widget.currentThemeMode},
                      onSelectionChanged: (Set<ThemeMode> newSelection) {
                        widget.onThemeModeChanged(newSelection.first);
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          // زر الترس للإعدادات في الزاوية العلوية
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).cardColor.withValues(alpha: 0.8),
                  child: IconButton(
                    icon: Icon(
                      Icons.settings,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: () => _showSettingsBottomSheet(context, loc),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.qr_code_scanner),
            label: loc.translate('scan_tab'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.auto_awesome),
            label: loc.translate('generate_tab'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.history),
            label: loc.translate('history_tab'),
          ),
        ],
      ),
    );
  }
}