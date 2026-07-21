import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/app_controller.dart';
import '../models/asset_model.dart';
import '../widgets/app_card.dart';
import 'task_page.dart';

class AssetDetailsPage extends StatefulWidget {
  const AssetDetailsPage({
    super.key,
    required this.controller,
    required this.asset,
  });

  final AppController controller;
  final AssetModel asset;

  @override
  State<AssetDetailsPage> createState() => _AssetDetailsPageState();
}

class _AssetDetailsPageState extends State<AssetDetailsPage> {
  final picker = ImagePicker();
  late AssetModel asset;

  AppController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    asset = widget.asset;
  }

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
                _assetPhoto(),
                const SizedBox(height: 12),
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

  Widget _assetPhoto() {
    final photo = asset.photo;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: _pickAssetPhoto,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            if (photo == null)
              Container(
                height: 190,
                width: double.infinity,
                color: const Color(0xFFE3F3EF),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  size: 64,
                  color: Color(0xFF1B6B5F),
                ),
              )
            else
              Image.memory(
                photo,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              color: Colors.black.withValues(alpha: 0.55),
              child: Row(
                children: [
                  const Icon(
                    Icons.add_a_photo_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    photo == null ? 'إضافة صورة للأصل' : 'تغيير صورة الأصل',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAssetPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('التقاط صورة بالكاميرا'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('اختيار صورة من المعرض'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final image = await picker.pickImage(
      source: source,
      imageQuality: 72,
      maxWidth: 1400,
    );
    if (image == null || !mounted) return;

    final bytes = await image.readAsBytes();
    await controller.updateAssetPhoto(asset: asset, photo: bytes);
    if (!mounted) return;
    setState(() => asset = asset.copyWith(photo: bytes));
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
