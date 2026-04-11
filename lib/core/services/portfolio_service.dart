import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/models/portfolio_data.dart';

class PortfolioService {
  static Future<PortfolioData> load() async {
    final json = await rootBundle.loadString('assets/data/portfolio.json');
    final map = jsonDecode(json) as Map<String, dynamic>;
    return PortfolioData.fromJson(map);
  }
}
