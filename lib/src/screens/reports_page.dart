import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../models/task_model.dart';
import '../widgets/app_card.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('التقارير')),
          body: RefreshIndicator(
            onRefresh: controller.load,
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ملخص محلي',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('الأصول: ${controller.assets.length}'),
                      Text('إجمالي المهام: ${controller.localTaskCount}'),
                      Text(
                        'مهام الصيانة الدورية: ${controller.maintenanceTaskCount}',
                      ),
                      Text('مهام إصلاح الأعطال: ${controller.faultTaskCount}'),
                      Text(
                        'صيانة موثقة بصور قبل/بعد: ${controller.maintenancePhotoPairCount}',
                      ),
                      Text(
                        'إجمالي صور المهام: ${controller.savedTaskPhotoCount}',
                      ),
                      Text('متوسط صحة الأصول: ${controller.averageHealth}%'),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'سجل المهام',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                if (controller.tasks.isEmpty)
                  const AppCard(child: Text('لا توجد مهام محفوظة بعد.'))
                else
                  for (final task in controller.tasks)
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.assetName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('${task.type} - ${task.createdAt}'),
                          Text(
                            task.completed
                                ? 'الإتمام: مكتملة بتاريخ ${task.completedAt}'
                                : 'الإتمام: غير مكتملة',
                          ),
                          if (task.faultType.isNotEmpty)
                            Text('نوع العطل: ${task.faultType}'),
                          Text('الملاحظات: ${task.notes}'),
                          Text('قطع الغيار: ${task.parts}'),
                          Text('الإجراء: ${task.resolution}'),
                          Text(
                            'الحالة بعد المهمة: ${task.statusAfter} - ${task.healthAfter}%',
                          ),
                          Text('الصور المحفوظة: ${_photoCount(task)}'),
                          _taskPhotos(task),
                          const Text('الحفظ: SQLite محلي'),
                        ],
                      ),
                    ),
              ],
            ),
          ),
        );
      },
    );
  }

  int _photoCount(TaskModel task) {
    return [
      task.maintenanceBeforePhoto,
      task.maintenancePhoto,
      task.maintenanceAfterPhoto,
      task.faultBeforePhoto,
      task.faultAfterPhoto,
    ].where((photo) => photo != null).length;
  }

  Widget _taskPhotos(TaskModel task) {
    final photos = _photoEntries(task);
    if (photos.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final photo in photos)
            SizedBox(
              width: 118,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      photo.value,
                      height: 84,
                      width: 118,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(photo.key, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<MapEntry<String, Uint8List>> _photoEntries(TaskModel task) {
    final entries = <MapEntry<String, Uint8List>>[];

    void add(String label, Uint8List? photo) {
      if (photo != null) entries.add(MapEntry(label, photo));
    }

    add('قبل الصيانة', task.maintenanceBeforePhoto);
    add('صورة الصيانة', task.maintenancePhoto);
    add('بعد الصيانة', task.maintenanceAfterPhoto);
    add('قبل الإصلاح', task.faultBeforePhoto);
    add('بعد الإصلاح', task.faultAfterPhoto);

    return entries;
  }
}
