import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../models/asset_model.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key, required this.controller, required this.asset});

  final AppController controller;
  final AssetModel asset;

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final notes = TextEditingController();
  final parts = TextEditingController();
  final signature = TextEditingController();
  String type = 'صيانة دورية';
  bool gps = false;
  bool photo = false;
  bool saving = false;

  @override
  void dispose() {
    notes.dispose();
    parts.dispose();
    signature.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تنفيذ مهمة')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            widget.asset.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            widget.asset.code,
            style: const TextStyle(color: Color(0xFF60746F)),
          ),
          const SizedBox(height: 14),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'صيانة دورية',
                label: Text('صيانة دورية'),
                icon: Icon(Icons.event_repeat),
              ),
              ButtonSegment(
                value: 'إصلاح عطل',
                label: Text('إصلاح عطل'),
                icon: Icon(Icons.build_outlined),
              ),
            ],
            selected: {type},
            onSelectionChanged: (value) => setState(() => type = value.first),
          ),
          const SizedBox(height: 14),
          _checkTile(
            icon: Icons.gps_fixed,
            title: 'إثبات الموقع',
            subtitle: gps
                ? 'تم التحقق محليًا من موقع المهمة'
                : 'اضغط لتأكيد وجود الفني عند الأصل',
            value: gps,
            onTap: () => setState(() => gps = true),
          ),
          _checkTile(
            icon: Icons.photo_camera_outlined,
            title: 'صورة قبل العمل',
            subtitle: photo
                ? 'تم تسجيل مسار الصورة محليًا'
                : 'اضغط لمحاكاة التقاط صورة',
            value: photo,
            onTap: () => setState(() => photo = true),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: notes,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'الملاحظات'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: parts,
            decoration: const InputDecoration(labelText: 'قطع الغيار'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: signature,
            decoration: const InputDecoration(labelText: 'التوقيع الرقمي'),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: saving ? null : complete,
            icon: saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: const Text('حفظ المهمة في SQLite'),
          ),
        ],
      ),
    );
  }

  Widget _checkTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: value ? const Color(0xFF1B6B5F) : Colors.grey,
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Icon(
          value ? Icons.check_circle : Icons.radio_button_unchecked,
        ),
      ),
    );
  }

  Future<void> complete() async {
    if (!gps || !photo || signature.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أكمل الموقع والصورة والتوقيع أولًا')),
      );
      return;
    }

    setState(() => saving = true);
    await widget.controller.completeTask(
      asset: widget.asset,
      type: type,
      notes: notes.text,
      parts: parts.text,
      signature: signature.text,
    );
    if (!mounted) return;
    setState(() => saving = false);
    Navigator.popUntil(context, (route) => route.isFirst);
  }
}
