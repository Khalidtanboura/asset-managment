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
                _line(Icons.place_outlined, 'الموقع: ${asset.location}'),
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
        ],
      ),
    );
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
