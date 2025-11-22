// lib/main.dart
import 'dart:io' show Platform;
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
import 'screens/garage_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/receipt_scan_screen.dart';
import 'services/database_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
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
      materialDarkTheme: ThemeData(
        useMaterial3: false,
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
        // CRITICAL: Force dark navigation bar theme
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Color(0xFF000000),
          indicatorColor: Color(0xFF667EEA),
          labelTextStyle: WidgetStatePropertyAll(
            TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          iconTheme: WidgetStatePropertyAll(
            IconThemeData(color: Colors.white),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF000000),
          selectedItemColor: Color(0xFF667EEA),
          unselectedItemColor: Colors.white54,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
      ),
      cupertinoDarkTheme: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(0xFF667EEA),
        scaffoldBackgroundColor: Color(0xFF000000),
        barBackgroundColor: Color(0xFF000000),
        textTheme: CupertinoTextThemeData(
          primaryColor: Color(0xFFFFFFFF),
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
      ],
      routes: {
        '/home': (context) => const MainNavigationScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
      },
      home: const AppInitializer(),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final isComplete = await DatabaseService.instance.isOnboardingComplete();
    
    if (mounted) {
      if (isComplete) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Navigator.of(context).pushReplacementNamed('/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF667EEA),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.local_gas_station,
                size: 64,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'FuelTrack Pro',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(
              color: Color(0xFF667EEA),
            ),
          ],
        ),
      ),
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
    const GarageScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Use AdaptiveScaffold for iOS, regular Scaffold for Android
    if (Platform.isIOS) {
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
            AdaptiveNavigationDestination(
              icon: 'car.fill',
              label: 'Garage',
            ),
          ],
          selectedIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
        floatingActionButton: _selectedIndex != 3
            ? Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Receipt Scan FAB
                  FloatingActionButton(
                    heroTag: 'receipt_scan',
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReceiptScanScreen(),
                        ),
                      );
                      if (mounted) {
                        setState(() {});
                      }
                    },
                    backgroundColor: const Color(0xFF10B981),
                    child: const Icon(Icons.receipt_long, size: 28, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  // Manual Add FAB
                  FloatingActionButton(
                    heroTag: 'manual_add',
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddFillupScreen(),
                        ),
                      );
                      if (result == true && mounted) {
                        setState(() {});
                      }
                    },
                    backgroundColor: const Color(0xFF667EEA),
                    child: const Icon(Icons.add, size: 32, color: Colors.white),
                  ),
                  const SizedBox(height: 70), // Space above navbar
                ],
              )
            : null,
      );
    }
    
    // Android: Use regular Material components
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF000000),
          border: Border(
            top: BorderSide(
              color: Color(0xFF2A2A2A),
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFF000000),
          selectedItemColor: const Color(0xFF667EEA),
          unselectedItemColor: Colors.white54,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Stats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_car),
              label: 'Garage',
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedIndex != 3
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Receipt Scan FAB
                FloatingActionButton(
                  heroTag: 'receipt_scan',
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReceiptScanScreen(),
                      ),
                    );
                    if (mounted) {
                      setState(() {});
                    }
                  },
                  backgroundColor: const Color(0xFF10B981),
                  child: const Icon(Icons.receipt_long, size: 28, color: Colors.white),
                ),
                const SizedBox(height: 16),
                // Manual Add FAB
                FloatingActionButton(
                  heroTag: 'manual_add',
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddFillupScreen(),
                      ),
                    );
                    if (result == true && mounted) {
                      setState(() {});
                    }
                  },
                  backgroundColor: const Color(0xFF667EEA),
                  child: const Icon(Icons.add, size: 32, color: Colors.white),
                ),
                const SizedBox(height: 70), // Space above navbar
              ],
            )
          : null,
    );
  }
}