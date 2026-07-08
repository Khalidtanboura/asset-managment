class TaskModel {
  const TaskModel({
    this.id,
    required this.assetId,
    required this.assetName,
    required this.type,
    required this.notes,
    required this.parts,
    required this.signature,
    required this.photoPath,
    required this.gpsVerified,
    required this.synced,
    required this.createdAt,
  });

  final int? id;
  final int assetId;
  final String assetName;
  final String type;
  final String notes;
  final String parts;
  final String signature;
  final String photoPath;
  final bool gpsVerified;
  final bool synced;
  final String createdAt;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'assetId': assetId,
      'assetName': assetName,
      'type': type,
      'notes': notes,
      'parts': parts,
      'signature': signature,
      'photoPath': photoPath,
      'gpsVerified': gpsVerified ? 1 : 0,
      'synced': synced ? 1 : 0,
      'createdAt': createdAt,
    };
  }

  factory TaskModel.fromMap(Map<String, Object?> map) {
    return TaskModel(
      id: map['id'] as int?,
      assetId: map['assetId'] as int,
      assetName: map['assetName'] as String,
      type: map['type'] as String,
      notes: map['notes'] as String,
      parts: map['parts'] as String,
      signature: map['signature'] as String,
      photoPath: map['photoPath'] as String,
      gpsVerified: map['gpsVerified'] == 1,
      synced: map['synced'] == 1,
      createdAt: map['createdAt'] as String,
    );
  }

  TaskModel copyWith({bool? synced}) {
    return TaskModel(
      id: id,
      assetId: assetId,
      assetName: assetName,
      type: type,
      notes: notes,
      parts: parts,
      signature: signature,
      photoPath: photoPath,
      gpsVerified: gpsVerified,
      synced: synced ?? this.synced,
      createdAt: createdAt,
    );
  }
}
