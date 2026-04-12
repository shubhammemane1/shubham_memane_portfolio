import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shubhammemaneportfolio/presentation/widgets/media_section.dart';

void main() {
  testWidgets('shows Screenshots title when no videos', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: MediaSection(screenshots: ['https://example.com/a.jpg'], videos: []),
      ),
    ));
    expect(find.text('Screenshots'), findsOneWidget);
    expect(find.text('Screenshots & Videos'), findsNothing);
  });

  testWidgets('shows Screenshots & Videos title when videos present', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: MediaSection(
          screenshots: ['https://example.com/a.jpg'],
          videos: ['https://youtube.com/watch?v=abc123'],
        ),
      ),
    ));
    expect(find.text('Screenshots & Videos'), findsOneWidget);
  });

  testWidgets('shows video badge on video thumbnails', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: MediaSection(
          screenshots: [],
          videos: ['https://youtube.com/watch?v=abc123'],
        ),
      ),
    ));
    expect(find.text('VIDEO'), findsOneWidget);
  });
}
