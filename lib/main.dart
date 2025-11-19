// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'screens/home_screen.dart';
import 'screens/add_fillup_screen.dart';
import 'screens/history_screen.dart';
import 'screens/stats_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF000000),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const FuelTrackProApp());
}

class FuelTrackProApp extends StatelessWidget {
  const FuelTrackProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveApp(
      title: 'FuelTrack Pro',
      themeMode: ThemeMode.dark,
      
      // Material theme for Android
      materialDarkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF000000),
        primaryColor: const Color(0xFF667EEA),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF667EEA),
          secondary: Color(0xFF667EEA),
          surface: Color(0xFF1A1A1A),
          background: Color(0xFF000000),
        ),
        cardColor: const Color(0xFF1A1A1A),
        dividerColor: const Color(0xFF2A2A2A),
        fontFamily: 'SF Pro Display',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF000000),
          foregroundColor: Colors.white,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarBrightness: Brightness.dark,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
      ),
      
      // Cupertino theme for iOS
      cupertinoDarkTheme: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(0xFF667EEA),
        scaffoldBackgroundColor: Color(0xFF000000),
        barBackgroundColor: Color(0xFF000000),
        textTheme: CupertinoTextThemeData(
          primaryColor: Color(0xFFFFFFFF),
        ),
      ),
      
      // Add localizations support
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
      ],
      
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const HistoryScreen(),
    const StatsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: AdaptiveBottomNavigationBar(
        useNativeBottomBar: true,
        items: [
          AdaptiveNavigationDestination(
            icon: 'house.fill',
            label: 'Home',
          ),
          AdaptiveNavigationDestination(
            icon: 'clock.fill',
            label: 'History',
          ),
          AdaptiveNavigationDestination(
            icon: 'chart.bar.fill',
            label: 'Stats',
          ),
        ],
        selectedIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      floatingActionButton: AdaptiveFloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddFillupScreen()),
          );
        },
        backgroundColor: const Color(0xFF667EEA),
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
    );
  }
}