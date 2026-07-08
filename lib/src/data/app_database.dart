import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/asset_model.dart';
import '../models/task_model.dart';

class AppDatabase {
  Database? _db;
  final List<AssetModel> _memoryAssets = [];
  final List<TaskModel> _memoryTasks = [];

  Future<Database?> get database async {
    if (_db != null) return _db;
    try {
      final path = join(await getDatabasesPath(), 'asset_management.db');
      _db = await openDatabase(path, version: 1, onCreate: _createTables);
      return _db;
    } on MissingPluginException {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE assets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        location TEXT NOT NULL,
        status TEXT NOT NULL,
        lastMaintenance TEXT NOT NULL,
        nextMaintenance TEXT NOT NULL,
        health INTEGER NOT NULL,
        manual TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        assetId INTEGER NOT NULL,
        assetName TEXT NOT NULL,
        type TEXT NOT NULL,
        notes TEXT NOT NULL,
        parts TEXT NOT NULL,
        signature TEXT NOT NULL,
        photoPath TEXT NOT NULL,
        gpsVerified INTEGER NOT NULL,
        synced INTEGER NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  Future<void> seedIfEmpty() async {
    final assets = await getAssets();
    if (assets.isNotEmpty) return;

    await addAsset(
      const AssetModel(
        code: 'GEN-001',
        name: 'مولد كهربائي رئيسي',
        category: 'طاقة',
        location: 'مبنى A - غرفة الطاقة',
        status: 'يعمل بكفاءة',
        lastMaintenance: '2026-01-07',
        nextMaintenance: '2026-07-07',
        health: 92,
        manual: 'فحص الزيت والفلاتر والوقود والاهتزاز.',
      ),
    );
    await addAsset(
      const AssetModel(
        code: 'PMP-014',
        name: 'مضخة مياه احتياطية',
        category: 'مرافق',
        location: 'القبو - محطة الضخ',
        status: 'بحاجة متابعة',
        lastMaintenance: '2026-03-12',
        nextMaintenance: '2026-09-12',
        health: 76,
        manual: 'اختبار الضغط وتنظيف الصمام وفحص التسريب.',
      ),
    );
  }

  Future<List<AssetModel>> getAssets() async {
    final db = await database;
    if (db == null) return List.unmodifiable(_memoryAssets);
    final rows = await db.query('assets', orderBy: 'id DESC');
    return rows.map(AssetModel.fromMap).toList();
  }

  Future<int> addAsset(AssetModel asset) async {
    final db = await database;
    if (db == null) {
      final id = _memoryAssets.length + 1;
      _memoryAssets.insert(0, asset.copyWith(id: id));
      return id;
    }
    return db.insert(
      'assets',
      asset.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateAsset(AssetModel asset) async {
    final db = await database;
    if (db == null) {
      final index = _memoryAssets.indexWhere((item) => item.id == asset.id);
      if (index != -1) _memoryAssets[index] = asset;
      return;
    }
    await db.update(
      'assets',
      asset.toMap(),
      where: 'id = ?',
      whereArgs: [asset.id],
    );
  }

  Future<List<TaskModel>> getTasks() async {
    final db = await database;
    if (db == null) return List.unmodifiable(_memoryTasks);
    final rows = await db.query('tasks', orderBy: 'id DESC');
    return rows.map(TaskModel.fromMap).toList();
  }

  Future<void> addTask(TaskModel task) async {
    final db = await database;
    if (db == null) {
      final id = _memoryTasks.length + 1;
      _memoryTasks.insert(0, TaskModel.fromMap({...task.toMap(), 'id': id}));
      return;
    }
    await db.insert('tasks', task.toMap());
  }

  Future<void> syncTasks() async {
    final db = await database;
    if (db == null) {
      for (var i = 0; i < _memoryTasks.length; i++) {
        _memoryTasks[i] = _memoryTasks[i].copyWith(synced: true);
      }
      return;
    }
    await db.update(
      'tasks',
      {'synced': 1},
      where: 'synced = ?',
      whereArgs: [0],
    );
  }
}
