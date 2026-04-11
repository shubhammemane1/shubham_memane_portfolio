import 'package:flutter/material.dart';
import '../../domain/models/portfolio_data.dart';

class ProjectDetailPage extends StatelessWidget {
  final Project project;
  const ProjectDetailPage({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(project.title)),
    );
  }
}
