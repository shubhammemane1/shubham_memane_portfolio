import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shubhammemaneportfolio/domain/models/portfolio_data.dart';
import 'package:shubhammemaneportfolio/presentation/pages/project_detail_page.dart';

void main() {
  final testProject = Project(
    title: 'Test App',
    description: 'Short description',
    technologies: ['Flutter', 'Dart'],
    slug: 'test-app',
    screenshots: [],
    longDescription: 'A longer description for testing.',
  );

  Widget _wrap(Project project) {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => ProjectDetailPage(project: project)),
    ]);
    return MaterialApp.router(routerConfig: router);
  }

  testWidgets('renders project title', (tester) async {
    await tester.pumpWidget(_wrap(testProject));
    await tester.pump();
    expect(find.text('Test App'), findsWidgets);
  });

  testWidgets('renders longDescription', (tester) async {
    await tester.pumpWidget(_wrap(testProject));
    await tester.pump();
    expect(find.text('A longer description for testing.'), findsOneWidget);
  });

  testWidgets('hides screenshots section when screenshots is empty', (tester) async {
    await tester.pumpWidget(_wrap(testProject));
    await tester.pump();
    expect(find.text('Screenshots'), findsNothing);
  });

  testWidgets('shows screenshots section when screenshots is non-empty', (tester) async {
    final withScreenshots = Project(
      title: 'Test App',
      description: 'desc',
      technologies: [],
      slug: 'test-app',
      screenshots: ['https://example.com/screen.png'],
    );
    await tester.pumpWidget(_wrap(withScreenshots));
    await tester.pump();
    expect(find.text('Screenshots'), findsOneWidget);
  });
}
