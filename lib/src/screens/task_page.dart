import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/app_controller.dart';
import '../models/asset_model.dart';
import '../models/task_model.dart';

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
  final resolution = TextEditingController();
  final picker = ImagePicker();

  String type = 'صيانة دورية';
  String faultType = 'كهربائي';
  String statusAfter = 'يعمل بكفاءة';
  int healthAfter = 96;
  late DateTime nextMaintenanceDate;
  Uint8List? maintenanceBeforePhoto;
  Uint8List? maintenanceAfterPhoto;
  Uint8List? faultBeforePhoto;
  Uint8List? faultAfterPhoto;
  bool saving = false;

  final faultTypes = const [
    'كهربائي',
    'ميكانيكي',
    'تسريب',
    'ارتفاع حرارة',
    'ضعف أداء',
    'كسر أو تلف',
    'أخرى',
  ];

  final statuses = const ['يعمل بكفاءة', 'بحاجة متابعة', 'متوقف مؤقتًا'];

  @override
  void initState() {
    super.initState();
    nextMaintenanceDate = _defaultNextMaintenanceDate();
  }

  @override
  void dispose() {
    notes.dispose();
    parts.dispose();
    resolution.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFault = type == 'إصلاح عطل';

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
          if (isFault) ..._faultFields() else ..._maintenanceFields(),
          const SizedBox(height: 8),
          _resultFields(),
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
            label: const Text('تنفيذ وتسجيل إتمام الصيانة'),
          ),
        ],
      ),
    );
  }

  List<Widget> _maintenanceFields() {
    return [
      if (_lastMaintenanceTask != null) ...[
        _previousMaintenancePhotos(_lastMaintenanceTask!),
        const SizedBox(height: 12),
      ],
      Row(
        children: [
          Expanded(
            child: _photoTile(
              title: 'قبل الصيانة',
              subtitle: 'صورة حالة الأصل قبل البدء',
              photo: maintenanceBeforePhoto,
              compact: true,
              onTap: () =>
                  _pickPhoto((bytes) => maintenanceBeforePhoto = bytes),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _photoTile(
              title: 'بعد الصيانة',
              subtitle: 'صورة النتيجة بعد الانتهاء',
              photo: maintenanceAfterPhoto,
              compact: true,
              onTap: () => _pickPhoto((bytes) => maintenanceAfterPhoto = bytes),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      TextField(
        controller: notes,
        maxLines: 3,
        decoration: const InputDecoration(
          labelText: 'ما الذي تم فحصه أو تنظيفه؟',
          prefixIcon: Icon(Icons.fact_check_outlined),
        ),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: parts,
        decoration: const InputDecoration(
          labelText: 'قطع الغيار أو المواد المستخدمة',
          prefixIcon: Icon(Icons.handyman_outlined),
        ),
      ),
    ];
  }

  TaskModel? get _lastMaintenanceTask {
    final assetId = widget.asset.id;
    if (assetId == null) return null;

    for (final task in widget.controller.tasks) {
      final hasMaintenancePhotos =
          task.maintenanceBeforePhoto != null ||
          task.maintenanceAfterPhoto != null;
      if (task.assetId == assetId &&
          task.type == 'صيانة دورية' &&
          task.completed &&
          hasMaintenancePhotos) {
        return task;
      }
    }
    return null;
  }

  Widget _previousMaintenancePhotos(TaskModel task) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.history, color: Color(0xFF1B6B5F)),
                SizedBox(width: 8),
                Text(
                  'آخر صيانة محفوظة',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${task.createdAt} - ${task.notes}',
              style: const TextStyle(color: Color(0xFF60746F)),
            ),
            if (task.nextMaintenanceDate.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'الصيانة القادمة: ${task.nextMaintenanceDate}',
                style: const TextStyle(color: Color(0xFF60746F)),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                _previousPhotoPreview('قبل', task.maintenanceBeforePhoto),
                const SizedBox(width: 8),
                _previousPhotoPreview('بعد', task.maintenanceAfterPhoto),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _previousPhotoPreview(String label, Uint8List? photo) {
    return Expanded(
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: photo == null
                  ? Container(
                      color: const Color(0xFFE8EFED),
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: Color(0xFF60746F),
                      ),
                    )
                  : Image.memory(photo, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  List<Widget> _faultFields() {
    return [
      DropdownButtonFormField<String>(
        initialValue: faultType,
        decoration: const InputDecoration(
          labelText: 'نوع العطل',
          prefixIcon: Icon(Icons.report_problem_outlined),
        ),
        items: [
          for (final item in faultTypes)
            DropdownMenuItem(value: item, child: Text(item)),
        ],
        onChanged: (value) => setState(() => faultType = value ?? faultType),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: _photoTile(
              title: 'قبل الإصلاح',
              subtitle: 'صورة العطل',
              photo: faultBeforePhoto,
              compact: true,
              onTap: () => _pickPhoto((bytes) => faultBeforePhoto = bytes),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _photoTile(
              title: 'بعد الإصلاح',
              subtitle: 'صورة النتيجة',
              photo: faultAfterPhoto,
              compact: true,
              onTap: () => _pickPhoto((bytes) => faultAfterPhoto = bytes),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      TextField(
        controller: notes,
        maxLines: 3,
        decoration: const InputDecoration(
          labelText: 'وصف العطل',
          prefixIcon: Icon(Icons.notes_outlined),
        ),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: resolution,
        maxLines: 3,
        decoration: const InputDecoration(
          labelText: 'الإجراء الذي تم لإصلاح العطل',
          prefixIcon: Icon(Icons.construction_outlined),
        ),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: parts,
        decoration: const InputDecoration(
          labelText: 'قطع الغيار المستبدلة',
          prefixIcon: Icon(Icons.handyman_outlined),
        ),
      ),
    ];
  }

  Widget _resultFields() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'نتيجة المهمة',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: statusAfter,
              decoration: const InputDecoration(
                labelText: 'حالة الأصل بعد المهمة',
                prefixIcon: Icon(Icons.verified_outlined),
              ),
              items: [
                for (final item in statuses)
                  DropdownMenuItem(value: item, child: Text(item)),
              ],
              onChanged: (value) =>
                  setState(() => statusAfter = value ?? statusAfter),
            ),
            const SizedBox(height: 8),
            Text('تقييم صحة الأصل: $healthAfter%'),
            Slider(
              value: healthAfter.toDouble(),
              min: 0,
              max: 100,
              divisions: 20,
              label: '$healthAfter%',
              onChanged: (value) => setState(() => healthAfter = value.round()),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_available_outlined),
              title: const Text('موعد الصيانة القادمة'),
              subtitle: Text(_formatDate(nextMaintenanceDate)),
              trailing: const Icon(Icons.edit_calendar_outlined),
              onTap: _pickNextMaintenanceDate,
            ),
          ],
        ),
      ),
    );
  }

  Widget _photoTile({
    required String title,
    required String subtitle,
    required Uint8List? photo,
    required VoidCallback onTap,
    bool compact = false,
  }) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(compact ? 10 : 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    photo == null
                        ? Icons.add_a_photo_outlined
                        : Icons.check_circle,
                    color: photo == null
                        ? Colors.grey
                        : const Color(0xFF1B6B5F),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                photo == null ? subtitle : 'تم إرفاق الصورة وحفظها مع المهمة',
                style: const TextStyle(color: Color(0xFF60746F)),
              ),
              if (photo != null) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.memory(
                    photo,
                    height: compact ? 96 : 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickPhoto(void Function(Uint8List bytes) savePhoto) async {
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
    setState(() => savePhoto(bytes));
  }

  Future<void> _pickNextMaintenanceDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: nextMaintenanceDate.isBefore(today)
          ? _defaultNextMaintenanceDate()
          : nextMaintenanceDate,
      firstDate: today,
      lastDate: DateTime(today.year + 5, today.month, today.day),
    );
    if (picked == null || !mounted) return;

    setState(() => nextMaintenanceDate = picked);
  }

  Future<void> complete() async {
    final isFault = type == 'إصلاح عطل';
    final missingMaintenancePhotos =
        !isFault &&
        (maintenanceBeforePhoto == null || maintenanceAfterPhoto == null);
    final missingFaultPhotos =
        isFault && (faultBeforePhoto == null || faultAfterPhoto == null);

    if (missingMaintenancePhotos || missingFaultPhotos) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFault
                ? 'أرفق صورة قبل الإصلاح وصورة بعد الإصلاح'
                : 'أرفق صورة قبل الصيانة وصورة بعد الصيانة',
          ),
        ),
      );
      return;
    }

    setState(() => saving = true);
    bool saved = false;
    try {
      saved = await widget.controller.completeTask(
        asset: widget.asset,
        type: type,
        faultType: isFault ? faultType : '',
        notes: notes.text,
        parts: parts.text,
        resolution: isFault ? resolution.text : 'صيانة دورية مكتملة',
        statusAfter: statusAfter,
        healthAfter: healthAfter,
        nextMaintenanceDate: _formatDate(nextMaintenanceDate),
        maintenanceBeforePhoto: maintenanceBeforePhoto,
        maintenancePhoto: null,
        maintenanceAfterPhoto: maintenanceAfterPhoto,
        faultBeforePhoto: faultBeforePhoto,
        faultAfterPhoto: faultAfterPhoto,
      );
    } catch (_) {
      saved = false;
    }
    if (!mounted) return;
    setState(() => saving = false);
    if (!saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تعذر حفظ المهمة. تأكد أن الأصل محفوظ وأن قاعدة البيانات تعمل.',
          ),
        ),
      );
      return;
    }
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  DateTime _defaultNextMaintenanceDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 6, now.day);
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${_two(date.month)}-${_two(date.day)}';
  }

  String _two(int value) => value.toString().padLeft(2, '0');
}
