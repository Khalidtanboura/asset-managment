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
          body: RefreshIndicator(
            onRefresh: controller.load,
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.storage_outlined,
                            color: Color(0xFF1B6B5F),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              controller.loading
                                  ? 'جاري قراءة SQLite...'
                                  : 'تطبيق Offline بالكامل',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),
                      Text('عدد الأصول: ${controller.assets.length}'),
                      Text(
                        'مهام الصيانة المحفوظة: ${controller.localTaskCount}',
                      ),
                      Text('متوسط صحة الأصول: ${controller.averageHealth}%'),
                      if (controller.errorMessage != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          controller.errorMessage!,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ],
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                if (controller.assets.isEmpty)
                  const AppCard(
                    child: Text('لا توجد أصول بعد. اضغط زر إضافة أصل للبدء.'),
                  )
                else
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
                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }
}
