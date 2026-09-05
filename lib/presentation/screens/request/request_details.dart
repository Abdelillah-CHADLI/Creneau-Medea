import 'package:flutter/material.dart';
import '../../../data/models/pitch.dart';
import '../../../main.dart';
import '../../theme/app_theme.dart';
import 'create_request_data.dart';

class RequestDetailsStep extends StatefulWidget {
  final CreateRequestData data;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const RequestDetailsStep({
    super.key,
    required this.data,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<RequestDetailsStep> createState() => _RequestDetailsStepState();
}

class _RequestDetailsStepState extends State<RequestDetailsStep> {
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  String? _pitchName;
  DateTime? _date;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  int? _playerCount;

  static const _playerOptions = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13];

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.data.title ?? '';
    _pitchName = widget.data.pitchName;
    _date = widget.data.date;
    _startTime = widget.data.startTime;
    _endTime = widget.data.endTime;
    _playerCount = widget.data.playerCount;
    _priceController.text = widget.data.price?.toString() ?? '';
  }

  void _save() {
    widget.data.title = _titleController.text.trim();
    widget.data.pitchName = _pitchName;
    widget.data.date = _date;
    widget.data.startTime = _startTime;
    widget.data.endTime = _endTime;
    widget.data.playerCount = _playerCount;
    widget.data.price = int.tryParse(_priceController.text.trim());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? const TimeOfDay(hour: 18, minute: 0),
    );
    if (picked != null) setState(() => _startTime = picked);
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? const TimeOfDay(hour: 19, minute: 0),
    );
    if (picked != null) setState(() => _endTime = picked);
  }

  String _formatTime(TimeOfDay? t) {
    if (t == null) return '--:-- --';
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'صباحاً' : 'مساءً';
    return '$h:$m $period';
  }

  String _formatDate(DateTime d) {
    return '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year}';
  }

  bool get _canProceed =>
      _titleController.text.trim().isNotEmpty &&
      _pitchName != null &&
      _date != null &&
      _startTime != null &&
      _endTime != null &&
      _playerCount != null;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildProgress(),
        Expanded(child: _buildBody()),
        _buildBottomBar(),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              _save();
              widget.onBack();
            },
            child: const Icon(
              Icons.arrow_forward_ios,
              size: 22,
              color: AppColors.textDark,
            ),
          ),
          const Spacer(),
          Text(
            'تفاصيل المباراة',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const Spacer(),
          const SizedBox(width: 26),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الخطوة 2 من 4',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              Text(
                'المعلومات الأساسية',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.5,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel('عنوان الطلب'),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            maxLength: 60,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'مثال: تحدي حي المصلى مساء الجمعة',
              prefixIcon: Icon(Icons.title_rounded),
              counterText: '',
            ),
          ),
          const SizedBox(height: 24),
          _buildFieldLabel('الملعب'),
          const SizedBox(height: 8),
          _buildPitchDropdown(),
          const SizedBox(height: 24),
          _buildFieldLabel('التاريخ'),
          const SizedBox(height: 8),
          _buildDatePicker(),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildFieldLabel('وقت البداية')),
              const SizedBox(width: 16),
              Expanded(child: _buildFieldLabel('وقت النهاية')),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildStartTimePicker()),
              const SizedBox(width: 16),
              Expanded(child: _buildEndTimePicker()),
            ],
          ),
          const SizedBox(height: 24),
          _buildFieldLabel('عدد اللاعبين المطلوبين'),
          const SizedBox(height: 10),
          _buildPlayerCountSelector(),
          const SizedBox(height: 24),
          _buildFieldLabel('السعر لكل لاعب (دج، اختياري)'),
          const SizedBox(height: 8),
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            textDirection: TextDirection.rtl,
            decoration: const InputDecoration(
              hintText: 'مثال: 500',
              prefixIcon: Icon(Icons.payments_outlined),
              suffixText: 'دج',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(label, style: Theme.of(context).textTheme.labelLarge),
    );
  }

  Widget _buildPitchDropdown() {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (ctx) => _PitchPickerSheet(
            selected: _pitchName,
            onSelected: (name) {
              setState(() => _pitchName = name);
              Navigator.pop(ctx);
            },
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.stadium_outlined,
              size: 20,
              color: AppColors.textMuted,
            ),
            const Spacer(),
            Text(
              _pitchName ?? 'اختر الملعب',
              style: TextStyle(
                fontSize: 14,
                color: _pitchName != null
                    ? AppColors.textDark
                    : AppColors.placeholder,
              ),
            ),
            const Spacer(),
            const Icon(Icons.expand_more, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Text(
              _date != null ? _formatDate(_date!) : 'mm/dd/yyyy',
              style: TextStyle(
                fontSize: 14,
                color: _date != null
                    ? AppColors.textDark
                    : AppColors.placeholder,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.calendar_today_outlined,
              size: 20,
              color: AppColors.textMuted,
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.calendar_month_outlined,
              size: 20,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartTimePicker() {
    return GestureDetector(
      onTap: _pickStartTime,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formatTime(_startTime),
              style: TextStyle(
                fontSize: 14,
                color: _startTime != null
                    ? AppColors.textDark
                    : AppColors.placeholder,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.access_time, size: 18, color: AppColors.textMuted),
            const SizedBox(width: 4),
            const Icon(
              Icons.timer_outlined,
              size: 18,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEndTimePicker() {
    return GestureDetector(
      onTap: _pickEndTime,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formatTime(_endTime),
              style: TextStyle(
                fontSize: 14,
                color: _endTime != null
                    ? AppColors.textDark
                    : AppColors.placeholder,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.access_time, size: 18, color: AppColors.textMuted),
            const SizedBox(width: 4),
            const Icon(Icons.update, size: 18, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerCountSelector() {
    return DropdownButtonFormField<int>(
      initialValue: _playerCount,
      isExpanded: true,
      decoration: const InputDecoration(
        hintText: 'اختر العدد المطلوب',
        prefixIcon: Icon(Icons.group_add_outlined),
      ),
      items: _playerOptions
          .map(
            (count) => DropdownMenuItem(
              value: count,
              child: Text(_playerCountLabel(count)),
            ),
          )
          .toList(),
      onChanged: (value) => setState(() => _playerCount = value),
    );
  }

  String _playerCountLabel(int count) {
    if (count == 1) return 'لاعب واحد';
    if (count == 2) return 'لاعبان';
    if (count <= 10) return '$count لاعبين';
    return '$count لاعباً';
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              child: ElevatedButton(
                onPressed: _canProceed
                    ? () {
                        _save();
                        widget.onNext();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'متابعة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textDark,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'إلغاء',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PitchPickerSheet extends StatefulWidget {
  final String? selected;
  final ValueChanged<String> onSelected;

  const _PitchPickerSheet({required this.selected, required this.onSelected});

  @override
  State<_PitchPickerSheet> createState() => _PitchPickerSheetState();
}

class _PitchPickerSheetState extends State<_PitchPickerSheet> {
  late final Future<List<Pitch>> _pitches = appData.pitches();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text('اختر الملعب', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Pitch>>(
                future: _pitches,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('تعذر تحميل الملاعب من قاعدة البيانات'),
                    );
                  }
                  final pitches = snapshot.data ?? const <Pitch>[];
                  if (pitches.isEmpty) {
                    return const Center(
                      child: Text('لا توجد ملاعب متاحة حالياً'),
                    );
                  }
                  return ListView.separated(
                    itemCount: pitches.length,
                    separatorBuilder: (_, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final pitch = pitches[index];
                      return ListTile(
                        leading: const Icon(Icons.stadium_outlined),
                        title: Text(pitch.name),
                        subtitle: pitch.location == null
                            ? null
                            : Text(pitch.location!),
                        trailing: widget.selected == pitch.name
                            ? const Icon(
                                Icons.check_circle,
                                color: AppColors.primary,
                              )
                            : null,
                        onTap: () => widget.onSelected(pitch.name),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
