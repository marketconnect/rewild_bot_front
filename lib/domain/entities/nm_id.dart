class NmId {
  final int nmId;

  NmId({
    required this.nmId,
  });

  // Convert a NmIdDb object into a Map. The keys must correspond to the names of the columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'nmId': nmId,
    };
  }
}
