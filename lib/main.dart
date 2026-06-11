import 'package:flutter/material.dart';
import 'screens/unit_converter_screen.dart';
import 'screens/currency_converter_screen.dart';

void main() {
  runApp(const MiniConvertersApp());
}

class MiniConvertersApp extends StatelessWidget {
  const MiniConvertersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Converters',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const HomeScreen(),
    );
  }
}

enum ScreenType { units, currency }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ScreenType screen = ScreenType.units;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini Converters'),
      ),
      body: screen == ScreenType.units
          ? const UnitConverterScreen()
          : const CurrencyConverterScreen(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: screen == ScreenType.units ? 0 : 1,
        onDestinationSelected: (index) {
          setState(() {
            screen = index == 0 ? ScreenType.units : ScreenType.currency;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.swap_horiz),
            label: 'Units',
          ),
          NavigationDestination(
            icon: Icon(Icons.currency_exchange),
            label: 'Currency',
          ),
        ],
      ),
    );
  }
}