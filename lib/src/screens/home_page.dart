import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../widgets/app_card.dart';
import '../widgets/asset_tile.dart';
import 'add_asset_page.dart';
import 'asset_details_page.dart';
import 'reports_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('إدارة الأصول'),
            actions: [
              IconButton(
                tooltip: controller.online ? 'متصل' : 'غير متصل',
                onPressed: controller.toggleOnline,
                icon: Icon(
                  controller.online ? Icons.cloud_done : Icons.cloud_off,
                ),
              ),
              IconButton(
                tooltip: 'التقارير',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReportsPage(controller: controller),
                  ),
                ),
                icon: const Icon(Icons.analytics_outlined),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddAssetPage(controller: controller),
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text('إضافة أصل'),
          ),
          body: controller.loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'لوحة المتابعة',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('عدد الأصول: ${controller.assets.length}'),
                          Text('مهام الصيانة: ${controller.tasks.length}'),
                          Text('غير متزامن: ${controller.pendingSync}'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: controller.assets.isEmpty
                          ? null
                          : () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AssetDetailsPage(
                                  controller: controller,
                                  asset: controller.assets.first,
                                ),
                              ),
                            ),
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('محاكاة مسح QR / NFC'),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'الأصول',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (final asset in controller.assets)
                      AssetTile(
                        asset: asset,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AssetDetailsPage(
                              controller: controller,
                              asset: asset,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
        );
      },
    );
  }
}
