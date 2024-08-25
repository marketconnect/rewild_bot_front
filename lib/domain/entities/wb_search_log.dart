class WbSearchLog {
  final int cpm;
  final String geo;
  final int promoPosition;
  final int position;

  final String tp;

  WbSearchLog(
      {required this.cpm,
      required this.promoPosition,
      required this.position,
      required this.geo,
      required this.tp});

  factory WbSearchLog.fromJson(Map<String, dynamic> json, String geo) {
    return WbSearchLog(
      geo: geo,
      cpm: json['cpm'] ?? 0,
      promoPosition: json['promoPosition'] ?? 0,
      position: json['position'] ?? 0,
      tp: json['tp'] ?? '',
    );
  }
}
