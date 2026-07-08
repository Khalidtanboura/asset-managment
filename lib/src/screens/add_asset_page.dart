import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../models/asset_model.dart';

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
  final category = TextEditingController();
  final location = TextEditingController();
  final manual = TextEditingController();

  @override
  void dispose() {
    code.dispose();
    name.dispose();
    category.dispose();
    location.dispose();
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
            _field(code, 'رقم الأصل / QR ID', Icons.qr_code),
            _field(name, 'اسم الأصل', Icons.inventory_2_outlined),
            _field(category, 'التصنيف', Icons.category_outlined),
            _field(location, 'الموقع', Icons.place_outlined),
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
        validator: (value) =>
            value == null || value.trim().isEmpty ? 'هذا الحقل مطلوب' : null,
        decoration: InputDecoration(prefixIcon: Icon(icon), labelText: label),
      ),
    );
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;
    await widget.controller.addAsset(
      AssetModel(
        code: code.text.trim(),
        name: name.text.trim(),
        category: category.text.trim(),
        location: location.text.trim(),
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
