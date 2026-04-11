// lib/presentation/pages/home_page.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../core/state/mouse_notifier.dart';
import '../../domain/models/portfolio_data.dart';
import '../widgets/nav_bar.dart';
import '../widgets/hero_section.dart';
import '../widgets/skills_section.dart';
import '../widgets/projects_section.dart';
import '../widgets/experience_section.dart';
import '../widgets/contact_section.dart';
import '../widgets/particle_canvas.dart';

class HomePage extends StatefulWidget {
  final PortfolioData portfolioData;
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const HomePage({super.key, required this.portfolioData, required this.onThemeToggle, required this.isDarkMode});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MouseNotifier _mouseNotifier = MouseNotifier(Offset.zero);
  final ScrollController _scrollController = ScrollController();

  final GlobalKey _heroKey = GlobalKey();
  final GlobalKey _skillsKey = GlobalKey();
  final GlobalKey _projectsKey = GlobalKey();
  final GlobalKey _experienceKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();

  void _onMouseMove(PointerHoverEvent event) {
    final size = MediaQuery.of(context).size;
    _mouseNotifier.value = Offset(
      (event.localPosition.dx - size.width / 2) / (size.width / 2),
      (event.localPosition.dy - size.height / 2) / (size.height / 2),
    );
  }

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOut,
    );
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _mouseNotifier.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MouseRegion(
        onHover: _onMouseMove,
        child: Stack(
          children: [
            Positioned.fill(
              child: ParticleCanvas(mouseNotifier: _mouseNotifier),
            ),
            SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  const SizedBox(height: 64), // space for Positioned NavBar
                  KeyedSubtree(
                    key: _heroKey,
                    child: HeroSection(
                      personalInfo: widget.portfolioData.personalInfo,
                      mouseNotifier: _mouseNotifier,
                    ),
                  ),
                  KeyedSubtree(
                    key: _skillsKey,
                    child: SkillsSection(skills: widget.portfolioData.skills),
                  ),
                  KeyedSubtree(
                    key: _projectsKey,
                    child: ProjectsSection(projects: widget.portfolioData.projects),
                  ),
                  KeyedSubtree(
                    key: _experienceKey,
                    child: ExperienceSection(experiences: widget.portfolioData.experiences),
                  ),
                  KeyedSubtree(
                    key: _contactKey,
                    child: ContactSection(contactInfo: widget.portfolioData.contactInfo),
                  ),
                  const _Footer(),
                ],
              ),
            ),
            Positioned(
              top: 0, left: 0, right: 0,
              child: NavBar(
                onThemeToggle: widget.onThemeToggle,
                isDarkMode: widget.isDarkMode,
                onAbout: _scrollToTop,
                onSkills: () => _scrollTo(_skillsKey),
                onProjects: () => _scrollTo(_projectsKey),
                onExperience: () => _scrollTo(_experienceKey),
                onContact: () => _scrollTo(_contactKey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Text(
        '© 2024 Shubham Memane. Built with Flutter',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[600]
              : Colors.grey[500],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
