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
          body: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ملخص سريع',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('متوسط صحة الأصول: ${controller.averageHealth}%'),
                    Text('عدد المهام: ${controller.tasks.length}'),
                    Text('المهام غير المتزامنة: ${controller.pendingSync}'),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: controller.sync,
                      icon: const Icon(Icons.sync),
                      label: const Text('مزامنة SQLite'),
                    ),
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
                      Text(task.synced ? 'متزامنة' : 'محفوظة محليًا'),
                    ],
                  ),
                ),
              if (controller.tasks.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(child: Text('لا توجد مهام بعد')),
                ),
            ],
          ),
        );
      },
    );
  }
}
