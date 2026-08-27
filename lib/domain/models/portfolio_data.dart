import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PortfolioData {
  final PersonalInfo personalInfo;
  final List<Skill> skills;
  final List<Project> projects;
  final List<Experience> experiences;
  final List<Education> education;
  final ContactInfo contactInfo;

  PortfolioData({
    required this.personalInfo,
    required this.skills,
    required this.projects,
    required this.experiences,
    required this.education,
    required this.contactInfo,
  });

  factory PortfolioData.fromJson(Map<String, dynamic> json) {
    return PortfolioData(
      personalInfo: PersonalInfo.fromJson(json['personalInfo'] as Map<String, dynamic>),
      skills: (json['skills'] as List<dynamic>)
          .map((e) => Skill.fromJson(e as Map<String, dynamic>))
          .toList(),
      projects: (json['projects'] as List<dynamic>)
          .map((e) => Project.fromJson(e as Map<String, dynamic>))
          .toList(),
      experiences: (json['experiences'] as List<dynamic>)
          .map((e) => Experience.fromJson(e as Map<String, dynamic>))
          .toList(),
      education: (json['education'] as List<dynamic>)
          .map((e) => Education.fromJson(e as Map<String, dynamic>))
          .toList(),
      contactInfo: ContactInfo.fromJson(json['contactInfo'] as Map<String, dynamic>),
    );
  }
}

class PersonalInfo {
  final String name;
  final String title;
  final String bio;
  final String? imageUrl;

  PersonalInfo({required this.name, required this.title, required this.bio, this.imageUrl});

  factory PersonalInfo.fromJson(Map<String, dynamic> json) {
    return PersonalInfo(
      name: json['name'] as String,
      title: json['title'] as String,
      bio: json['bio'] as String,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

class Skill {
  final String name;
  final String category;
  final double proficiency;

  Skill({required this.name, required this.category, required this.proficiency});

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      name: json['name'] as String,
      category: json['category'] as String,
      proficiency: (json['proficiency'] as num).toDouble(),
    );
  }
}

class Project {
  final String title;
  final String description;
  final List<String> technologies;
  final String? imageUrl;
  final String? liveUrl;
  final String? githubUrl;
  final String? playStoreUrl;
  final String? appStoreUrl;
  final FaIconData? icon;
  final String slug;
  final List<String> screenshots;
  final List<String> videos;
  final String? longDescription;
  final double? rating;
  final String? downloads;

  Project({
    required this.title,
    required this.description,
    required this.technologies,
    this.imageUrl,
    this.liveUrl,
    this.githubUrl,
    this.playStoreUrl,
    this.appStoreUrl,
    this.icon,
    required this.slug,
    this.screenshots = const [],
    this.videos = const [],
    this.longDescription,
    this.rating,
    this.downloads,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    final title = json['title'] as String;
    return Project(
      title: title,
      description: json['description'] as String,
      technologies: (json['technologies'] as List<dynamic>).cast<String>(),
      imageUrl: json['imageUrl'] as String?,
      liveUrl: json['liveUrl'] as String?,
      githubUrl: json['githubUrl'] as String?,
      playStoreUrl: json['playStoreUrl'] as String?,
      appStoreUrl: json['appStoreUrl'] as String?,
      icon: _iconFromString(json['icon'] as String?),
      slug: json['slug'] as String? ?? _slugify(title),
      screenshots: (json['screenshots'] as List<dynamic>?)?.cast<String>() ?? const [],
      videos: (json['videos'] as List<dynamic>?)?.cast<String>() ?? const [],
      longDescription: json['longDescription'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      downloads: json['downloads'] as String?,
    );
  }

  static String _slugify(String title) {
    return title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }

  static FaIconData? _iconFromString(String? name) {
    switch (name) {
      case 'cartShopping':  return FontAwesomeIcons.cartShopping;
      case 'listCheck':     return FontAwesomeIcons.listCheck;
      case 'cloudSunRain':  return FontAwesomeIcons.cloudSunRain;
      case 'mobileScreen':  return FontAwesomeIcons.mobileScreen;
      case 'globe':         return FontAwesomeIcons.globe;
      case 'database':      return FontAwesomeIcons.database;
      case 'robot':         return FontAwesomeIcons.robot;
      case 'chartLine':     return FontAwesomeIcons.chartLine;
      case 'lock':          return FontAwesomeIcons.lock;
      case 'gamepad':       return FontAwesomeIcons.gamepad;
      default:              return null;
    }
  }
}

class Experience {
  final String company;
  final String position;
  final String duration;
  final String description;

  Experience({required this.company, required this.position, required this.duration, required this.description});

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      company: json['company'] as String,
      position: json['position'] as String,
      duration: json['duration'] as String,
      description: json['description'] as String,
    );
  }
}

class Education {
  final String institution;
  final String degree;
  final String duration;

  Education({required this.institution, required this.degree, required this.duration});

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      institution: json['institution'] as String,
      degree: json['degree'] as String,
      duration: json['duration'] as String,
    );
  }
}

class ContactInfo {
  final String email;
  final String? phone;
  final String? github;
  final String? linkedin;
  final String? twitter;
  final String? website;

  ContactInfo({required this.email, this.phone, this.github, this.linkedin, this.twitter, this.website});

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      email: json['email'] as String,
      phone: json['phone'] as String?,
      github: json['github'] as String?,
      linkedin: json['linkedin'] as String?,
      twitter: json['twitter'] as String?,
      website: json['website'] as String?,
    );
  }
}
