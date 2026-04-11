import 'package:flutter_test/flutter_test.dart';
import 'package:shubhammemaneportfolio/domain/models/portfolio_data.dart';

void main() {
  test('Project.fromJson parses slug, screenshots, longDescription', () {
    final json = {
      'title': 'Test App',
      'description': 'Short desc',
      'technologies': ['Flutter'],
      'slug': 'test-app',
      'screenshots': ['https://example.com/s1.png', 'https://example.com/s2.png'],
      'longDescription': 'Long detailed description.',
    };
    final project = Project.fromJson(json);
    expect(project.slug, 'test-app');
    expect(project.screenshots, ['https://example.com/s1.png', 'https://example.com/s2.png']);
    expect(project.longDescription, 'Long detailed description.');
  });

  test('Project.fromJson defaults screenshots to empty list when absent', () {
    final json = {
      'title': 'Test App',
      'description': 'Short desc',
      'technologies': ['Flutter'],
      'slug': 'test-app',
    };
    final project = Project.fromJson(json);
    expect(project.screenshots, isEmpty);
    expect(project.longDescription, isNull);
  });

  test('Project.fromJson auto-slugifies title when slug absent', () {
    final json = {
      'title': 'My Cool App',
      'description': 'desc',
      'technologies': <String>[],
    };
    final project = Project.fromJson(json);
    expect(project.slug, 'my-cool-app');
  });
}
