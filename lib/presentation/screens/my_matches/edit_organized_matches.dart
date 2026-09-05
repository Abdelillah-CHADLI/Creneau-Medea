import 'package:flutter/material.dart';

import '../../../data/models/game.dart';
import '../../../main.dart';
import '../../theme/app_theme.dart';

class EditOrganizedMatchScreen extends StatefulWidget {
  final Game game;

  const EditOrganizedMatchScreen({super.key, required this.game});

  @override
  State<EditOrganizedMatchScreen> createState() =>
      _EditOrganizedMatchScreenState();
}

class _EditOrganizedMatchScreenState extends State<EditOrganizedMatchScreen> {
  late final TextEditingController _title;
  late final TextEditingController _price;
  late final TextEditingController _capacity;
  late final TextEditingController _notes;
  late DateTime _start;
  late DateTime _end;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.game.title);
    _price = TextEditingController(text: widget.game.price?.toString() ?? '');
    _capacity = TextEditingController(text: widget.game.maxPlayers.toString());
    _notes = TextEditingController(text: widget.game.body ?? '');
    _start = widget.game.startingTime;
    _end = widget.game.endingTime;
  }

  @override
  void dispose() {
    _title.dispose();
    _price.dispose();
    _capacity.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime(bool isStart) async {
    final current = isStart ? _start : _end;
    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (time == null) return;
    final value = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    setState(() {
      if (isStart) {
        _start = value;
      } else {
        _end = value;
      }
    });
  }

  Future<void> _save() async {
    final capacity = int.tryParse(_capacity.text.trim());
    final price = _price.text.trim().isEmpty
        ? null
        : int.tryParse(_price.text.trim());
    if (_title.text.trim().isEmpty ||
        capacity == null ||
        capacity < 1 ||
        capacity > 13 ||
        price != null && price < 0 ||
        !_end.isAfter(_start)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تحقق من العنوان، السعر، السعة، ووقت المباراة'),
        ),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await appData.updateGame(
        widget.game.id,
        title: _title.text.trim(),
        startingTime: _start,
        endingTime: _end,
        body: _notes.text.trim(),
        price: price,
        maxPlayers: capacity,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('تعذر حفظ التعديلات: $error')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      appBar: AppBar(title: const Text('تعديل المباراة')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _label('عنوان المباراة'),
          TextField(controller: _title),
          const SizedBox(height: 16),
          _label('السعر لكل لاعب (دج)'),
          TextField(controller: _price, keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          _label('الحد الأقصى للاعبين'),
          TextField(controller: _capacity, keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          _label('موعد البداية'),
          _dateTile(_start, () => _pickDateTime(true)),
          const SizedBox(height: 12),
          _label('موعد النهاية'),
          _dateTile(_end, () => _pickDateTime(false)),
          const SizedBox(height: 16),
          _label('ملاحظات'),
          TextField(controller: _notes, maxLines: 4),
          const SizedBox(height: 28),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('حفظ التعديلات'),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: Theme.of(context).textTheme.labelLarge),
  );
  Widget _dateTile(DateTime value, VoidCallback onTap) => ListTile(
    tileColor: AppColors.card,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: AppColors.border),
    ),
    leading: const Icon(
      Icons.calendar_month_outlined,
      color: AppColors.primary,
    ),
    title: Text(
      '${value.day}/${value.month}/${value.year} · ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}',
    ),
    onTap: onTap,
  );
}
