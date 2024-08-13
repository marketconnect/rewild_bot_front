// ignore_for_file: public_member_api_docs, sort_constructors_first
class Warehouse {
  final int id;
  final String name;

  Warehouse({required this.name, required this.id});

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      id: json['storeId'],
      name: json['storeName'].toString().trim(),
    );
  }

  @override
  String toString() => 'Warehouse(id: $id, name: $name)';
}
