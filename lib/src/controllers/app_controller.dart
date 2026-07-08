import 'package:flutter/material.dart';

import '../data/app_database.dart';
import '../models/asset_model.dart';
import '../models/task_model.dart';

class AppController extends ChangeNotifier {
  AppController(this.db);

  final AppDatabase db;

  List<AssetModel> assets = [];
  List<TaskModel> tasks = [];
  bool loading = true;
  bool online = true;

  int get pendingSync => tasks.where((task) => !task.synced).length;

  int get averageHealth {
    if (assets.isEmpty) return 0;
    final total = assets.fold<int>(0, (sum, asset) => sum + asset.health);
    return (total / assets.length).round();
  }

  Future<void> load() async {
    loading = true;
    notifyListeners();
    await db.seedIfEmpty();
    assets = await db.getAssets();
    tasks = await db.getTasks();
    loading = false;
    notifyListeners();
  }

  Future<void> addAsset(AssetModel asset) async {
    await db.addAsset(asset);
    await load();
  }

  Future<void> completeTask({
    required AssetModel asset,
    required String type,
    required String notes,
    required String parts,
    required String signature,
  }) async {
    final today = _today();
    await db.addTask(
      TaskModel(
        assetId: asset.id!,
        assetName: asset.name,
        type: type,
        notes: notes.trim().isEmpty ? 'لا توجد ملاحظات' : notes.trim(),
        parts: parts.trim().isEmpty ? 'لم يتم استبدال قطع' : parts.trim(),
        signature: signature.trim(),
        photoPath: 'local/${asset.code}-before.jpg',
        gpsVerified: true,
        synced: online,
        createdAt: today,
      ),
    );

    await db.updateAsset(
      asset.copyWith(
        status: 'يعمل بكفاءة',
        health: 96,
        lastMaintenance: today,
        nextMaintenance: _afterSixMonths(),
      ),
    );
    await load();
  }

  Future<void> sync() async {
    online = true;
    await db.syncTasks();
    await load();
  }

  void toggleOnline() {
    online = !online;
    notifyListeners();
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
