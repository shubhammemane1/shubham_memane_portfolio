import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/services/portfolio_service.dart';
import 'domain/models/portfolio_data.dart';
import 'presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final data = await PortfolioService.load();
  runApp(MyApp(portfolioData: data));
}

class MyApp extends StatefulWidget {
  final PortfolioData portfolioData;

  const MyApp({super.key, required this.portfolioData});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = true;

  void _toggleTheme() {
    setState(() => _isDarkMode = !_isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shubham Memane - Portfolio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: HomePage(
        portfolioData: widget.portfolioData,
        onThemeToggle: _toggleTheme,
        isDarkMode: _isDarkMode,
      ),
    );
  }
}
