class GeoSearchModel {
  final int nmId;
  final int position;
  final int? advCpm;
  final int? advPosition;
  const GeoSearchModel({
    required this.nmId,
    required this.position,
    this.advCpm,
    this.advPosition,
  });
}
