import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../models/asset_model.dart';
import 'qr_scanner_page.dart';

class AddAssetPage extends StatefulWidget {
  const AddAssetPage({super.key, required this.controller});

  final AppController controller;

  @override
  State<AddAssetPage> createState() => _AddAssetPageState();
}

class _AddAssetPageState extends State<AddAssetPage> {
  final formKey = GlobalKey<FormState>();
  final code = TextEditingController();
  final name = TextEditingController();
  final manual = TextEditingController();

  final categories = const [
    'طاقة',
    'مرافق',
    'تكييف وتبريد',
    'أمن وسلامة',
    'شبكات واتصالات',
    'معدات طبية',
    'مركبات',
    'أثاث وتجهيزات',
  ];

  String? selectedCategory;

  @override
  void dispose() {
    code.dispose();
    name.dispose();
    manual.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة أصل')),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            TextFormField(
              controller: code,
              validator: _required,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.qr_code),
                labelText: 'رقم الأصل / QR ID',
                suffixIcon: IconButton(
                  tooltip: 'فتح الكاميرا',
                  onPressed: scanQr,
                  icon: const Icon(Icons.photo_camera_outlined),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _field(name, 'اسم الأصل', Icons.inventory_2_outlined),
            DropdownButtonFormField<String>(
              initialValue: selectedCategory,
              validator: (value) => value == null ? 'اختر التصنيف' : null,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.category_outlined),
                labelText: 'التصنيف',
              ),
              items: [
                for (final category in categories)
                  DropdownMenuItem(value: category, child: Text(category)),
              ],
              onChanged: (value) => setState(() => selectedCategory = value),
            ),
            const SizedBox(height: 12),
            _field(
              manual,
              'تعليمات التشغيل والصيانة',
              Icons.menu_book_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: save,
              icon: const Icon(Icons.save_outlined),
              label: const Text('حفظ في SQLite'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: _required,
        decoration: InputDecoration(prefixIcon: Icon(icon), labelText: label),
      ),
    );
  }

  String? _required(String? value) {
    return value == null || value.trim().isEmpty ? 'هذا الحقل مطلوب' : null;
  }

  Future<void> scanQr() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QrScannerPage()),
    );
    if (result == null || !mounted) return;
    code.text = result;
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;
    await widget.controller.addAsset(
      AssetModel(
        code: code.text.trim(),
        name: name.text.trim(),
        category: selectedCategory!,
        location: 'غير محدد',
        status: 'يعمل بكفاءة',
        lastMaintenance: 'لم تتم بعد',
        nextMaintenance: 'غير مجدولة',
        health: 100,
        manual: manual.text.trim(),
      ),
    );
    if (mounted) Navigator.pop(context);
  }
}
