import 'dart:convert';

class MediaFilesDbItem {
  final int? cardItemId;

  final String type;
  final String localFilePath;
  final String url;
  final String hash;
  // final bool? old;
  final DateTime updatedAt;

  const MediaFilesDbItem(
      {this.cardItemId,
      // this.old,
      this.type = 'photo',
      required this.localFilePath,
      required this.url,
      required this.hash,
      required this.updatedAt});

  MediaFilesDbItem copyWith({
    int? cardItemId,
    String? type,
    String? localFilePath,
    String? url,
    String? hash,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MediaFilesDbItem(
      cardItemId: cardItemId ?? this.cardItemId,
      type: type ?? this.type,
      localFilePath: localFilePath ?? this.localFilePath,
      url: url ?? this.url,
      hash: hash ?? this.hash,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'cardItemId': cardItemId,
      'type': type,
      'localFilePath': localFilePath,
      'url': url,
      'hash': hash,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory MediaFilesDbItem.fromMap(Map<String, dynamic> map) {
    return MediaFilesDbItem(
      cardItemId: map['cardItemId'] as int,
      type: map['type'] as String,
      localFilePath: map['localFilePath'] as String,
      url: map['url'] as String,
      hash: map['hash'] as String,
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  String toJson() => json.encode(toMap());

  factory MediaFilesDbItem.fromJson(String source) =>
      MediaFilesDbItem.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'MediaFilesDbItem(cardItemId: $cardItemId, type: $type, localFilePath: $localFilePath, url: $url, hash: $hash, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(covariant MediaFilesDbItem other) {
    if (identical(this, other)) return true;

    return other.cardItemId == cardItemId &&
        other.type == type &&
        other.localFilePath == localFilePath &&
        other.url == url &&
        other.hash == hash &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return cardItemId.hashCode ^
        type.hashCode ^
        localFilePath.hashCode ^
        url.hashCode ^
        hash.hashCode ^
        updatedAt.hashCode;
  }
}
