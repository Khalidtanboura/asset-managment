import 'dart:typed_data';

class AssetModel {
  const AssetModel({
    this.id,
    required this.code,
    required this.name,
    required this.category,
    required this.location,
    required this.status,
    required this.lastMaintenance,
    required this.nextMaintenance,
    required this.health,
    required this.manual,
    this.photo,
  });

  final int? id;
  final String code;
  final String name;
  final String category;
  final String location;
  final String status;
  final String lastMaintenance;
  final String nextMaintenance;
  final int health;
  final String manual;
  final Uint8List? photo;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'category': category,
      'location': location,
      'status': status,
      'lastMaintenance': lastMaintenance,
      'nextMaintenance': nextMaintenance,
      'health': health,
      'manual': manual,
      'photo': photo,
    };
  }

  factory AssetModel.fromMap(Map<String, Object?> map) {
    return AssetModel(
      id: map['id'] as int?,
      code: map['code'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      location: map['location'] as String,
      status: map['status'] as String,
      lastMaintenance: map['lastMaintenance'] as String,
      nextMaintenance: map['nextMaintenance'] as String,
      health: map['health'] as int,
      manual: map['manual'] as String,
      photo: map['photo'] as Uint8List?,
    );
  }

  AssetModel copyWith({
    int? id,
    String? status,
    String? lastMaintenance,
    String? nextMaintenance,
    int? health,
    Uint8List? photo,
  }) {
    return AssetModel(
      id: id ?? this.id,
      code: code,
      name: name,
      category: category,
      location: location,
      status: status ?? this.status,
      lastMaintenance: lastMaintenance ?? this.lastMaintenance,
      nextMaintenance: nextMaintenance ?? this.nextMaintenance,
      health: health ?? this.health,
      manual: manual,
      photo: photo ?? this.photo,
    );
  }
}
