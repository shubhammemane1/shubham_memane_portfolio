import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/services/portfolio_service.dart';
import 'core/router/app_router.dart';
import 'domain/models/portfolio_data.dart';

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
  late final _router = createRouter(
    portfolioData: widget.portfolioData,
    onThemeToggle: _toggleTheme,
    isDarkMode: () => _isDarkMode,
  );

  void _toggleTheme() {
    setState(() => _isDarkMode = !_isDarkMode);
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Shubham Memane - Portfolio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: _router,
    );
  }
}
