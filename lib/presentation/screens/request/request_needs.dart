import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'create_request_data.dart';

class RequestNeedsStep extends StatefulWidget {
  final CreateRequestData data;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const RequestNeedsStep({
    super.key,
    required this.data,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<RequestNeedsStep> createState() => _RequestNeedsStepState();
}

class _RequestNeedsStepState extends State<RequestNeedsStep> {
  final _notesController = TextEditingController();
  List<String> _selectedEquipment = [];

  static const _equipmentOptions = [
    _EquipmentItem(
      id: 'football',
      label: 'الكرة مطلوبة',
      icon: Icons.sports_soccer,
    ),
    _EquipmentItem(id: 'pump', label: 'مضخة مطلوبة', icon: Icons.air),
  ];

  @override
  void initState() {
    super.initState();
    _selectedEquipment = List.from(widget.data.equipment);
    _notesController.text = widget.data.notes ?? '';
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _toggleEquipment(String id) {
    setState(() {
      if (_selectedEquipment.contains(id)) {
        _selectedEquipment.remove(id);
      } else {
        _selectedEquipment.add(id);
      }
    });
    widget.data.equipment = List.of(_selectedEquipment);
  }

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
            onTap: widget.onBack,
            child: const Icon(
              Icons.arrow_forward_ios,
              size: 22,
              color: AppColors.textDark,
            ),
          ),
          const Spacer(),
          Text('إنشاء طلب', style: Theme.of(context).textTheme.headlineSmall),
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
                'الخطوة 3 من 4',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              Text(
                'المعدات والملاحظات',
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
              value: 0.75,
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'المعدات المطلوبة',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'اختر ما تحتاجه لهذه المباراة، إن وُجد.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildEquipmentGrid(),
          const SizedBox(height: 32),
          _buildNotesSection(),
        ],
      ),
    );
  }

  Widget _buildEquipmentGrid() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _equipmentOptions.map((item) {
        final isSelected = _selectedEquipment.contains(item.id);
        return SizedBox(
          width: (MediaQuery.sizeOf(context).width - 60) / 2,
          child: GestureDetector(
            onTap: () => _toggleEquipment(item.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primarySurface
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withAlpha(25)
                          : AppColors.neutralSurface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item.icon,
                      size: 28,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ملاحظات إضافية (اختياري)',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'ملاحظات للمشاركة',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          maxLines: 5,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          onChanged: (value) => widget.data.notes = value,
          decoration: InputDecoration(
            hintText:
                'أضف أي تفاصيل حول المباراة، شروط اللاعبين، أو كيفية التواصل معك في الملعب...',
            hintStyle: const TextStyle(
              color: AppColors.placeholder,
              fontSize: 13,
              height: 1.6,
            ),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            widget.data.equipment = List.of(_selectedEquipment);
            widget.data.notes = _notesController.text;
            widget.onNext();
          },
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
              Icon(Icons.check_circle_outline, size: 22),
              SizedBox(width: 8),
              Text(
                'مراجعة الطلب',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EquipmentItem {
  final String id;
  final String label;
  final IconData icon;

  const _EquipmentItem({
    required this.id,
    required this.label,
    required this.icon,
  });
}
