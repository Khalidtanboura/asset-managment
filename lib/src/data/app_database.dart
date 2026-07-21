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
      final databasesPath = await getDatabasesPath().timeout(
        const Duration(seconds: 2),
      );
      final path = join(databasesPath, 'asset_management.db');
      _db = await openDatabase(
        path,
        version: 7,
        onCreate: _createTables,
        onUpgrade: _upgradeTables,
      ).timeout(const Duration(seconds: 3));
      return _db;
    } on MissingPluginException {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS assets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        location TEXT NOT NULL,
        status TEXT NOT NULL,
        lastMaintenance TEXT NOT NULL,
        nextMaintenance TEXT NOT NULL,
        health INTEGER NOT NULL,
        manual TEXT NOT NULL,
        photo BLOB
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        assetId INTEGER NOT NULL,
        assetName TEXT NOT NULL,
        type TEXT NOT NULL,
        faultType TEXT NOT NULL,
        notes TEXT NOT NULL,
        parts TEXT NOT NULL,
        resolution TEXT NOT NULL,
        statusAfter TEXT NOT NULL,
        healthAfter INTEGER NOT NULL,
        maintenanceBeforePhoto BLOB,
        maintenancePhoto BLOB,
        maintenanceAfterPhoto BLOB,
        faultBeforePhoto BLOB,
        faultAfterPhoto BLOB,
        completed INTEGER NOT NULL,
        completedAt TEXT NOT NULL,
        synced INTEGER NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  Future<void> _upgradeTables(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 3) {
      await _resetTables(db, newVersion);
      return;
    }
    if (oldVersion < 4) {
      await _addColumnIfMissing(db, 'assets', 'photo', 'BLOB');
    }
    if (oldVersion < 5) {
      await _addColumnIfMissing(db, 'tasks', 'maintenanceBeforePhoto', 'BLOB');
      await _addColumnIfMissing(db, 'tasks', 'maintenanceAfterPhoto', 'BLOB');
    }
    if (oldVersion < 6) {
      await _addColumnIfMissing(
        db,
        'tasks',
        'completed',
        'INTEGER NOT NULL DEFAULT 1',
      );
      await _addColumnIfMissing(
        db,
        'tasks',
        'completedAt',
        'TEXT NOT NULL DEFAULT ""',
      );
      await db.execute(
        'UPDATE tasks SET completedAt = createdAt WHERE completedAt = ""',
      );
    }
    if (oldVersion < 7) {
      await _ensureTaskPhotoColumns(db);
    }
  }

  Future<void> _ensureTaskPhotoColumns(Database db) async {
    await _addColumnIfMissing(db, 'tasks', 'maintenanceBeforePhoto', 'BLOB');
    await _addColumnIfMissing(db, 'tasks', 'maintenancePhoto', 'BLOB');
    await _addColumnIfMissing(db, 'tasks', 'maintenanceAfterPhoto', 'BLOB');
    await _addColumnIfMissing(db, 'tasks', 'faultBeforePhoto', 'BLOB');
    await _addColumnIfMissing(db, 'tasks', 'faultAfterPhoto', 'BLOB');
  }

  Future<void> _addColumnIfMissing(
    Database db,
    String table,
    String column,
    String definition,
  ) async {
    final columns = await db.rawQuery('PRAGMA table_info($table)');
    final exists = columns.any((row) => row['name'] == column);
    if (!exists) {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $definition');
    }
  }

  Future<void> _resetTables(Database db, int version) async {
    await db.execute('DROP TABLE IF EXISTS tasks');
    await db.execute('DROP TABLE IF EXISTS assets');
    await _createTables(db, version);
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
    try {
      final rows = await db.query('assets', orderBy: 'id DESC');
      return rows.map(AssetModel.fromMap).toList();
    } catch (_) {
      return List.unmodifiable(_memoryAssets);
    }
  }

  Future<int> addAsset(AssetModel asset) async {
    final db = await database;
    if (db == null) {
      final id = _memoryAssets.length + 1;
      _memoryAssets.insert(0, asset.copyWith(id: id));
      return id;
    }
    try {
      return db.insert(
        'assets',
        asset.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (_) {
      final id = _memoryAssets.length + 1;
      _memoryAssets.insert(0, asset.copyWith(id: id));
      return id;
    }
  }

  Future<void> updateAsset(AssetModel asset) async {
    final db = await database;
    if (db == null) {
      final index = _memoryAssets.indexWhere((item) => item.id == asset.id);
      if (index != -1) _memoryAssets[index] = asset;
      return;
    }
    try {
      await db.update(
        'assets',
        asset.toMap(),
        where: 'id = ?',
        whereArgs: [asset.id],
      );
    } catch (_) {
      final index = _memoryAssets.indexWhere((item) => item.id == asset.id);
      if (index != -1) _memoryAssets[index] = asset;
    }
  }

  Future<void> deleteAsset(AssetModel asset) async {
    final db = await database;
    if (db == null) {
      _memoryTasks.removeWhere((task) => task.assetId == asset.id);
      _memoryAssets.removeWhere((item) => item.id == asset.id);
      return;
    }
    try {
      await db.delete('tasks', where: 'assetId = ?', whereArgs: [asset.id]);
      await db.delete('assets', where: 'id = ?', whereArgs: [asset.id]);
    } catch (_) {
      _memoryTasks.removeWhere((task) => task.assetId == asset.id);
      _memoryAssets.removeWhere((item) => item.id == asset.id);
    }
  }

  Future<List<TaskModel>> getTasks() async {
    final db = await database;
    if (db == null) return List.unmodifiable(_memoryTasks);
    try {
      final rows = await db.query('tasks', orderBy: 'id DESC');
      return rows.map(TaskModel.fromMap).toList();
    } catch (_) {
      return List.unmodifiable(_memoryTasks);
    }
  }

  Future<void> addTask(TaskModel task) async {
    final db = await database;
    if (db == null) {
      final id = _memoryTasks.length + 1;
      _memoryTasks.insert(0, TaskModel.fromMap({...task.toMap(), 'id': id}));
      return;
    }
    try {
      await db.insert('tasks', task.toMap());
    } catch (_) {
      try {
        await _ensureTaskPhotoColumns(db);
        await db.insert('tasks', task.toMap());
      } catch (_) {
        rethrow;
      }
    }
  }
}
