// ignore_for_file: public_member_api_docs, sort_constructors_first
class PromptDetails {
  final String prompt;
  final String role;
  const PromptDetails({
    required this.prompt,
    required this.role,
  });

  factory PromptDetails.fromMap(Map<String, dynamic> map) {
    return PromptDetails(
      prompt: map['prompt'],
      role: map['role'],
    );
  }

  factory PromptDetails.fromJson(Map<String, dynamic> json) {
    return PromptDetails(
      prompt: json['prompt'],
      role: json['role'],
    );
  }

  factory PromptDetails.empty() {
    return const PromptDetails(
      role: '',
      prompt: '',
    );
  }

  // copyWith

  PromptDetails copyWith({
    String? prompt,
    String? role,
  }) {
    return PromptDetails(
      prompt: prompt ?? this.prompt,
      role: role ?? this.role,
    );
  }
}

class PromptDetailsForDescription extends PromptDetails {
  String title;
  String material;
  String color;
  String size;

  List<String> features;
  List<String> benefits;
  List<String> keywords;

  PromptDetailsForDescription({
    this.title = '',
    this.material = '',
    this.color = '',
    this.size = '',
    this.features = const [],
    this.benefits = const [],
    this.keywords = const [],
    required super.role,
    required super.prompt,
  });

  String get featuresAsString => features.join('\n');
  String get benefitsAsString => benefits.join('\n');
  String get keywordsAsString => keywords.join(', ');

  void updateFeatures(String featuresString) {
    features = featuresString.split('\n').map((e) => e.trim()).toList();
  }

  void updateBenefits(String benefitsString) {
    benefits = benefitsString.split('\n').map((e) => e.trim()).toList();
  }

  void updateKeywords(String keywordsString) {
    keywords = keywordsString.split(',').map((e) => e.trim()).toList();
  }
}
