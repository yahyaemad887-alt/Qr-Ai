import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/app_localizations.dart';
import 'core/theme.dart';
import 'models/qr_item.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة قاعدة البيانات المحلية Hive للسجل
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(QRItemAdapter());
  }
  await Hive.openBox<QRItem>('qr_history');

  final prefs = await SharedPreferences.getInstance();

  // فحص ما إذا كانت هذه هي المرة الأولى لفتح التطبيق
  final bool isFirstRun = prefs.getBool('is_first_run') ?? true;
  final String? savedLang = prefs.getString('selected_language');
  final String? savedTheme = prefs.getString('selected_theme');

  Locale initialLocale = savedLang != null ? Locale(savedLang) : const Locale('ar');
  ThemeMode initialTheme = savedTheme == 'dark'
      ? ThemeMode.dark
      : (savedTheme == 'light' ? ThemeMode.light : ThemeMode.system);

  runApp(QRAiApp(
    isFirstRun: isFirstRun,
    initialLocale: initialLocale,
    initialTheme: initialTheme,
  ));
}

class QRAiApp extends StatefulWidget {
  final bool isFirstRun;
  final Locale initialLocale;
  final ThemeMode initialTheme;

  const QRAiApp({
    super.key,
    required this.isFirstRun,
    required this.initialLocale,
    required this.initialTheme,
  });

  @override
  State<QRAiApp> createState() => _QRAiAppState();
}

class _QRAiAppState extends State<QRAiApp> {
  late Locale _locale;
  late ThemeMode _themeMode;
  late bool _isFirstRun;

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
    _themeMode = widget.initialTheme;
    _isFirstRun = widget.isFirstRun;
  }

  void _changeLocale(Locale newLocale) async {
    setState(() {
      _locale = newLocale;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', newLocale.languageCode);
  }

  void _changeThemeMode(ThemeMode newThemeMode) async {
    setState(() {
      _themeMode = newThemeMode;
    });
    final prefs = await SharedPreferences.getInstance();
    String themeStr = 'system';
    if (newThemeMode == ThemeMode.dark) themeStr = 'dark';
    if (newThemeMode == ThemeMode.light) themeStr = 'light';
    await prefs.setString('selected_theme', themeStr);
  }

  void _completeFirstRun(Locale selectedLocale) async {
    _changeLocale(selectedLocale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_run', false);
    setState(() {
      _isFirstRun = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      locale: _locale,
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
        Locale('es'),
        Locale('fr'),
        Locale('de'),
        Locale('ru'),
        Locale('pt'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: _isFirstRun
          ? LanguageSelectionScreen(
        onLanguageSelected: _completeFirstRun,
        onLocaleChanged: _changeLocale,
      )
          : HomeScreen(
        onLocaleChanged: _changeLocale,
        onThemeModeChanged: _changeThemeMode,
        currentThemeMode: _themeMode,
      ),
    );
  }
}

// شاشة اختيار اللغة للمرة الأولى فقط
class LanguageSelectionScreen extends StatefulWidget {
  final Function(Locale) onLanguageSelected;
  final Function(Locale) onLocaleChanged;

  const LanguageSelectionScreen({
    super.key,
    required this.onLanguageSelected,
    required this.onLocaleChanged,
  });

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String _selectedCode = 'ar';

  final Map<String, String> _languages = {
    'ar': 'العربية',
    'en': 'English',
    'es': 'Español',
    'fr': 'Français',
    'de': 'Deutsch',
    'ru': 'Русский',
    'pt': 'Português',
  };

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.language,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 24),
              Text(
                loc?.translate('select_language_title') ?? 'اختر اللغة',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                loc?.translate('select_language_subtitle') ??
                    'حدد لغتك المفضلة للبدء في استخدام التطبيق',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).primaryColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCode,
                    isExpanded: true,
                    items: _languages.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(
                          entry.value,
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedCode = val;
                        });
                        widget.onLocaleChanged(Locale(val));
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onLanguageSelected(Locale(_selectedCode));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    loc?.translate('continue_button') ?? 'متابعة',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}