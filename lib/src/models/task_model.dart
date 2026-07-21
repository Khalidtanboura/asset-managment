import 'dart:typed_data';

class TaskModel {
  const TaskModel({
    this.id,
    required this.assetId,
    required this.assetName,
    required this.type,
    required this.faultType,
    required this.notes,
    required this.parts,
    required this.resolution,
    required this.statusAfter,
    required this.healthAfter,
    required this.maintenanceBeforePhoto,
    required this.maintenancePhoto,
    required this.maintenanceAfterPhoto,
    required this.faultBeforePhoto,
    required this.faultAfterPhoto,
    required this.completed,
    required this.completedAt,
    required this.synced,
    required this.createdAt,
  });

  final int? id;
  final int assetId;
  final String assetName;
  final String type;
  final String faultType;
  final String notes;
  final String parts;
  final String resolution;
  final String statusAfter;
  final int healthAfter;
  final Uint8List? maintenanceBeforePhoto;
  final Uint8List? maintenancePhoto;
  final Uint8List? maintenanceAfterPhoto;
  final Uint8List? faultBeforePhoto;
  final Uint8List? faultAfterPhoto;
  final bool completed;
  final String completedAt;
  final bool synced;
  final String createdAt;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'assetId': assetId,
      'assetName': assetName,
      'type': type,
      'faultType': faultType,
      'notes': notes,
      'parts': parts,
      'resolution': resolution,
      'statusAfter': statusAfter,
      'healthAfter': healthAfter,
      'maintenanceBeforePhoto': maintenanceBeforePhoto,
      'maintenancePhoto': maintenancePhoto,
      'maintenanceAfterPhoto': maintenanceAfterPhoto,
      'faultBeforePhoto': faultBeforePhoto,
      'faultAfterPhoto': faultAfterPhoto,
      'completed': completed ? 1 : 0,
      'completedAt': completedAt,
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
      faultType: map['faultType'] as String? ?? '',
      notes: map['notes'] as String,
      parts: map['parts'] as String,
      resolution: map['resolution'] as String? ?? '',
      statusAfter: map['statusAfter'] as String? ?? 'يعمل بكفاءة',
      healthAfter: map['healthAfter'] as int? ?? 96,
      maintenanceBeforePhoto: map['maintenanceBeforePhoto'] as Uint8List?,
      maintenancePhoto: map['maintenancePhoto'] as Uint8List?,
      maintenanceAfterPhoto: map['maintenanceAfterPhoto'] as Uint8List?,
      faultBeforePhoto: map['faultBeforePhoto'] as Uint8List?,
      faultAfterPhoto: map['faultAfterPhoto'] as Uint8List?,
      completed: (map['completed'] as int? ?? 1) == 1,
      completedAt: map['completedAt'] as String? ?? map['createdAt'] as String,
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
      faultType: faultType,
      notes: notes,
      parts: parts,
      resolution: resolution,
      statusAfter: statusAfter,
      healthAfter: healthAfter,
      maintenanceBeforePhoto: maintenanceBeforePhoto,
      maintenancePhoto: maintenancePhoto,
      maintenanceAfterPhoto: maintenanceAfterPhoto,
      faultBeforePhoto: faultBeforePhoto,
      faultAfterPhoto: faultAfterPhoto,
      completed: completed,
      completedAt: completedAt,
      synced: synced ?? this.synced,
      createdAt: createdAt,
    );
  }
}
