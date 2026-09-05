import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/services/portfolio_service.dart';
import 'core/router/app_router.dart';
import 'domain/models/portfolio_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Preload web fonts before first paint so text is laid out with its real
  // metrics up front, instead of a fallback font's — otherwise the
  // Experience cards can briefly overflow once the real font swaps in and
  // text rewraps to more lines. Best-effort: never block startup on it.
  GoogleFonts.inter();
  GoogleFonts.spaceMono();
  GoogleFonts.bricolageGrotesque();
  await GoogleFonts.pendingFonts().timeout(const Duration(seconds: 3)).catchError((_) => const <void>[]);
  runApp(PortfolioBootstrap());
}

class PortfolioBootstrap extends StatefulWidget {
  final Future<PortfolioData> Function() loader;

  PortfolioBootstrap({super.key, Future<PortfolioData> Function()? loader})
      : loader = loader ?? PortfolioService.load;

  @override
  State<PortfolioBootstrap> createState() => _PortfolioBootstrapState();
}

class _PortfolioBootstrapState extends State<PortfolioBootstrap> {
  late Future<PortfolioData> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.loader();
  }

  void _retry() {
    setState(() {
      _future = widget.loader();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PortfolioData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }
        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Failed to load portfolio: ${snapshot.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _retry, child: const Text('Retry')),
                  ],
                ),
              ),
            ),
          );
        }
        return MyApp(portfolioData: snapshot.data!);
      },
    );
  }
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
