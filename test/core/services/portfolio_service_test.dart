import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shubhammemaneportfolio/core/services/portfolio_service.dart';

void main() {
  test('loads portfolio data from Firestore', () async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('portfolio').doc('meta').set({
      'personalInfo': {
        'name': 'Test User',
        'title': 'Developer',
        'bio': 'Bio text',
        'imageUrl': null,
      },
      'skills': [
        {'name': 'Flutter', 'category': 'Mobile', 'proficiency': 0.9},
      ],
      'experiences': [
        {
          'company': 'Acme',
          'position': 'Engineer',
          'duration': '2020-2022',
          'description': 'Built things',
        },
      ],
      'education': [
        {'institution': 'Uni', 'degree': 'BSc', 'duration': '2016-2020'},
      ],
      'contactInfo': {
        'email': 'test@example.com',
        'phone': null,
        'github': null,
        'linkedin': null,
        'twitter': null,
        'website': null,
      },
    });
    await firestore.collection('projects').doc('demo').set({
      'title': 'Demo Project',
      'description': 'A demo',
      'technologies': ['Flutter'],
      'imageUrl': 'https://example.com/icon.png',
      'liveUrl': null,
      'githubUrl': null,
      'playStoreUrl': null,
      'appStoreUrl': null,
      'icon': null,
      'slug': 'demo',
      'screenshots': <String>[],
      'videos': <String>[],
      'longDescription': null,
      'rating': null,
      'downloads': null,
    });

    final data = await PortfolioService.load(firestore: firestore);

    expect(data.personalInfo.name, 'Test User');
    expect(data.skills.single.name, 'Flutter');
    expect(data.projects.single.slug, 'demo');
    expect(data.contactInfo.email, 'test@example.com');
  });

  test('throws when portfolio/meta document is missing', () async {
    final firestore = FakeFirebaseFirestore();

    expect(
      () => PortfolioService.load(firestore: firestore),
      throwsA(isA<StateError>()),
    );
  });
}
