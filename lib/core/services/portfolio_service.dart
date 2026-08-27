import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/portfolio_data.dart';

class PortfolioService {
  static Future<PortfolioData> load({FirebaseFirestore? firestore}) async {
    final db = firestore ?? FirebaseFirestore.instance;

    final metaSnapshot = await db.collection('portfolio').doc('meta').get();
    final metaData = metaSnapshot.data();
    if (metaData == null) {
      throw StateError('portfolio/meta document not found in Firestore');
    }

    final projectsSnapshot = await db.collection('projects').orderBy('order').get();
    final projects = projectsSnapshot.docs.map((doc) => doc.data()).toList();

    return PortfolioData.fromJson({
      ...metaData,
      'projects': projects,
    });
  }
}
