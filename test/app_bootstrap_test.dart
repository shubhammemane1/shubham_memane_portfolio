import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shubhammemaneportfolio/main.dart';
import 'package:shubhammemaneportfolio/domain/models/portfolio_data.dart';

PortfolioData _fakeData() {
  return PortfolioData(
    personalInfo: PersonalInfo(name: 'Test', title: 'Dev', bio: 'Bio'),
    skills: const [],
    projects: const [],
    experiences: const [],
    education: const [],
    contactInfo: ContactInfo(email: 'a@b.com'),
  );
}

void main() {
  testWidgets('shows retry button on failure, recovers on tap', (tester) async {
    var attempt = 0;
    Future<PortfolioData> loader() async {
      attempt++;
      if (attempt == 1) {
        throw Exception('network down');
      }
      return _fakeData();
    }

    await tester.pumpWidget(PortfolioBootstrap(loader: loader));
    await tester.pumpAndSettle();

    expect(find.textContaining('Failed to load portfolio'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Retry'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Retry'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Failed to load portfolio'), findsNothing);
    expect(attempt, 2);
  });
}
