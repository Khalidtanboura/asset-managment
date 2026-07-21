import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../data/app_database.dart';
import '../models/asset_model.dart';
import '../models/task_model.dart';

class AppController extends ChangeNotifier {
  AppController(this.db);

  final AppDatabase db;

  List<AssetModel> assets = [];
  List<TaskModel> tasks = [];
  bool loading = false;
  String? errorMessage;

  int get localTaskCount => tasks.length;

  int get maintenanceTaskCount => tasks.where(_isMaintenanceTask).length;

  int get faultTaskCount => tasks.where(_isFaultTask).length;

  int get maintenancePhotoPairCount => tasks.where((task) {
    return task.maintenanceBeforePhoto != null &&
        task.maintenanceAfterPhoto != null;
  }).length;

  int get savedTaskPhotoCount {
    return tasks.fold<int>(0, (total, task) {
      return total +
          [
            task.maintenanceBeforePhoto,
            task.maintenancePhoto,
            task.maintenanceAfterPhoto,
            task.faultBeforePhoto,
            task.faultAfterPhoto,
          ].where((photo) => photo != null).length;
    });
  }

  int get averageHealth {
    if (assets.isEmpty) return 0;
    final total = assets.fold<int>(0, (sum, asset) => sum + asset.health);
    return (total / assets.length).round();
  }

  bool _isMaintenanceTask(TaskModel task) {
    return task.type == 'صيانة دورية' ||
        task.maintenanceBeforePhoto != null ||
        task.maintenancePhoto != null ||
        task.maintenanceAfterPhoto != null;
  }

  bool _isFaultTask(TaskModel task) {
    return task.type == 'إصلاح عطل' ||
        task.faultType.isNotEmpty ||
        task.faultBeforePhoto != null ||
        task.faultAfterPhoto != null;
  }

  Future<void> load() async {
    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await db.seedIfEmpty();
      assets = await db.getAssets();
      tasks = await db.getTasks();
    } catch (_) {
      errorMessage = 'تعذر فتح SQLite، لكن التطبيق بقي في الوضع المحلي.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> addAsset(AssetModel asset) async {
    await db.addAsset(asset);
    await load();
  }

  Future<void> deleteAsset(AssetModel asset) async {
    await db.deleteAsset(asset);
    await load();
  }

  Future<void> updateAssetPhoto({
    required AssetModel asset,
    required Uint8List photo,
  }) async {
    await db.updateAsset(asset.copyWith(photo: photo));
    await load();
  }

  Future<bool> completeTask({
    required AssetModel asset,
    required String type,
    required String faultType,
    required String notes,
    required String parts,
    required String resolution,
    required String statusAfter,
    required int healthAfter,
    Uint8List? maintenanceBeforePhoto,
    Uint8List? maintenancePhoto,
    Uint8List? maintenanceAfterPhoto,
    Uint8List? faultBeforePhoto,
    Uint8List? faultAfterPhoto,
  }) async {
    final assetId = asset.id;
    if (assetId == null) return false;

    final today = _today();
    await db.addTask(
      TaskModel(
        assetId: assetId,
        assetName: asset.name,
        type: type,
        faultType: faultType.trim(),
        notes: notes.trim().isEmpty ? 'لا توجد ملاحظات' : notes.trim(),
        parts: parts.trim().isEmpty ? 'لم يتم استبدال قطع' : parts.trim(),
        resolution: resolution.trim().isEmpty
            ? 'تمت المعالجة حسب الإجراء الفني'
            : resolution.trim(),
        statusAfter: statusAfter,
        healthAfter: healthAfter,
        maintenanceBeforePhoto: maintenanceBeforePhoto,
        maintenancePhoto: maintenancePhoto,
        maintenanceAfterPhoto: maintenanceAfterPhoto,
        faultBeforePhoto: faultBeforePhoto,
        faultAfterPhoto: faultAfterPhoto,
        completed: true,
        completedAt: today,
        synced: false,
        createdAt: today,
      ),
    );

    await db.updateAsset(
      asset.copyWith(
        status: statusAfter,
        health: healthAfter,
        lastMaintenance: today,
        nextMaintenance: _afterSixMonths(),
      ),
    );
    await load();
    return true;
  }

  String _today() {
    final now = DateTime.now();
    return '${now.year}-${_two(now.month)}-${_two(now.day)}';
  }

  String _afterSixMonths() {
    final now = DateTime.now();
    final next = DateTime(now.year, now.month + 6, now.day);
    return '${next.year}-${_two(next.month)}-${_two(next.day)}';
  }

  String _two(int value) => value.toString().padLeft(2, '0');
}
