// ignore_for_file: public_member_api_docs, sort_constructors_first
class AdvertNm {
  int nm;
  bool active;

  AdvertNm({
    required this.nm,
    required this.active,
  });

  factory AdvertNm.fromJson(Map<String, dynamic> json) {
    return AdvertNm(
      nm: json['nm'],
      active: json['active'],
    );
  }

  @override
  String toString() => 'AdvertNm(nm: $nm, active: $active)';
}
