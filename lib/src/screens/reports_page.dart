import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
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
                      Text('مهام الصيانة: ${controller.tasks.length}'),
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
                          Text('الملاحظات: ${task.notes}'),
                          Text('قطع الغيار: ${task.parts}'),
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
}
