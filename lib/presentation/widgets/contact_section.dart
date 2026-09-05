import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../domain/models/portfolio_data.dart';

class ContactSection extends StatelessWidget {
  final ContactInfo contactInfo;

  const ContactSection({super.key, required this.contactInfo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.value(context, mobile: AppSpacing.lg, desktop: AppSpacing.xxxl),
        vertical: AppSpacing.xxxl,
      ),
      child: Column(
        children: [
          Text('Get In Touch', style: Responsive.value(context, mobile: Theme.of(context).textTheme.displaySmall, desktop: Theme.of(context).textTheme.displayMedium)),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Feel free to reach out for collaborations or just a friendly hello',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.lg,
            alignment: WrapAlignment.center,
            children: [
              if (contactInfo.resumeUrl != null && contactInfo.resumeUrl!.isNotEmpty)
                _SocialButton(icon: FontAwesomeIcons.fileArrowDown, label: 'Resume', onTap: () => _launchUrl(contactInfo.resumeUrl!)),
              _SocialButton(icon: FontAwesomeIcons.envelope, label: 'Email', onTap: () => _launchUrl('mailto:${contactInfo.email}')),
              if (contactInfo.github != null)
                _SocialButton(icon: FontAwesomeIcons.github, label: 'GitHub', onTap: () => _launchUrl(contactInfo.github!)),
              if (contactInfo.linkedin != null)
                _SocialButton(icon: FontAwesomeIcons.linkedin, label: 'LinkedIn', onTap: () => _launchUrl(contactInfo.linkedin!)),
              if (contactInfo.twitter != null)
                _SocialButton(icon: FontAwesomeIcons.twitter, label: 'Twitter', onTap: () => _launchUrl(contactInfo.twitter!)),
            ],
          ),
        ],
      ),
    );
  }

  void _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}

class _SocialButton extends StatefulWidget {
  final FaIconData icon;
  final String label;
  final VoidCallback onTap;

  const _SocialButton({required this.icon, required this.label, required this.onTap});

  @override
  State<_SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<_SocialButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: _isHovered ? AppColors.primary : (Theme.of(context).brightness == Brightness.dark ? AppColors.darkSurface : AppColors.lightSurface),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(widget.icon, size: 20, color: _isHovered ? Colors.white : AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                widget.label,
                style: TextStyle(
                  color: _isHovered ? Colors.white : AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
