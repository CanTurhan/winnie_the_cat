import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:winnie_the_cat/core/theme/app_theme.dart';
import 'package:winnie_the_cat/l10n/app_localizations.dart';
import 'package:winnie_the_cat/providers/cat_provider.dart';
import 'package:winnie_the_cat/screens/home_screen.dart';
import 'package:winnie_the_cat/screens/settings_screen.dart';

void main() {
  runApp(const WinnieTheCatApp());
}

class WinnieTheCatApp extends StatefulWidget {
  const WinnieTheCatApp({super.key});

  @override
  State<WinnieTheCatApp> createState() => _WinnieTheCatAppState();
}

class _WinnieTheCatAppState extends State<WinnieTheCatApp> {
  Locale _locale = const Locale('en');

  void _changeLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CatProvider()..loadCats(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: _locale,
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
        theme: AppTheme.lightTheme,
        supportedLocales: const [
          Locale('en'),
          Locale('tr'),
        ],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: MainNavigation(
          currentLocale: _locale,
          onChangeLocale: _changeLocale,
        ),
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  final Locale currentLocale;
  final void Function(Locale locale) onChangeLocale;

  const MainNavigation({
    super.key,
    required this.currentLocale,
    required this.onChangeLocale,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final screens = [
      const HomeScreen(),
      SettingsScreen(
        currentLocale: widget.currentLocale,
        onChangeLocale: widget.onChangeLocale,
      ),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (value) {
          setState(() {
            _currentIndex = value;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.pets_outlined),
            selectedIcon: const Icon(Icons.pets),
            label: l10n.album,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.settings,
          ),
        ],
      ),
    );
  }
}
