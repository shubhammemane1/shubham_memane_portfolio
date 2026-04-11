import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/portfolio_data.dart';
import '../../presentation/pages/home_page.dart';
import '../../presentation/pages/project_detail_page.dart';

GoRouter createRouter({
  required PortfolioData portfolioData,
  required VoidCallback onThemeToggle,
  required bool Function() isDarkMode,
}) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => HomePage(
          portfolioData: portfolioData,
          onThemeToggle: onThemeToggle,
          isDarkMode: isDarkMode(),
        ),
      ),
      GoRoute(
        path: '/project/:slug',
        builder: (context, state) {
          final slug = state.pathParameters['slug']!;
          final project = portfolioData.projects.firstWhere(
            (p) => p.slug == slug,
            orElse: () => portfolioData.projects.first,
          );
          return ProjectDetailPage(project: project);
        },
      ),
    ],
  );
}
