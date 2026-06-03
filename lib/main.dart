import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'widgets/nav_rail.dart';
import 'screens/home_screen.dart';
import 'screens/learn/learn_screen.dart';
import 'screens/simulator/simulator_screen.dart';
import 'screens/algorithms/algorithms_screen.dart';
import 'screens/quiz/quiz_screen.dart';

void main() {
  runApp(const QuantumSimulatorApp());
}

class QuantumSimulatorApp extends StatelessWidget {
  const QuantumSimulatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quantum Computing Simulator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainLayout(),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(onNavigate: _onNavigate),
      const LearnScreen(),
      const SimulatorScreen(),
      const AlgorithmsScreen(),
      const QuizScreen(),
    ];
  }

  void _onNavigate(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      body: isMobile
          ? _screens[_selectedIndex]
          : Row(
              children: [
                AppNavRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _onNavigate,
                ),
                Expanded(child: _screens[_selectedIndex]),
              ],
            ),
      bottomNavigationBar: isMobile
          ? AppBottomNavBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onNavigate,
            )
          : null,
    );
  }
}
