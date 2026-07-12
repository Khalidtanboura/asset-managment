import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../models/asset_model.dart';
import '../widgets/app_card.dart';
import 'task_page.dart';

class AssetDetailsPage extends StatelessWidget {
  const AssetDetailsPage({
    super.key,
    required this.controller,
    required this.asset,
  });

  final AppController controller;
  final AssetModel asset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(asset.name)),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _line(Icons.qr_code, 'الرقم: ${asset.code}'),
                _line(Icons.category_outlined, 'التصنيف: ${asset.category}'),
                _line(
                  Icons.health_and_safety_outlined,
                  'الحالة: ${asset.status}',
                ),
                _line(Icons.favorite_outline, 'الصحة: ${asset.health}%'),
                _line(Icons.history, 'آخر صيانة: ${asset.lastMaintenance}'),
                _line(
                  Icons.event_available,
                  'الصيانة القادمة: ${asset.nextMaintenance}',
                ),
                _line(Icons.menu_book_outlined, asset.manual),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TaskPage(controller: controller, asset: asset),
              ),
            ),
            icon: const Icon(Icons.build_outlined),
            label: const Text('بدء مهمة صيانة'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => _confirmDelete(context),
            icon: const Icon(Icons.delete_outline),
            label: const Text('حذف الأصل'),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الأصل'),
        content: Text('هل تريد حذف "${asset.name}" وكل مهامه المحفوظة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    await controller.deleteAsset(asset);
    if (context.mounted) Navigator.popUntil(context, (route) => route.isFirst);
  }

  Widget _line(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF1B6B5F)),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
