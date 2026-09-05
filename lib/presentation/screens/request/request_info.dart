import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'create_request_data.dart';

class RequestInfoStep extends StatefulWidget {
  final CreateRequestData data;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const RequestInfoStep({
    super.key,
    required this.data,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<RequestInfoStep> createState() => _RequestInfoStepState();
}

class _RequestInfoStepState extends State<RequestInfoStep> {
  RequestType? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.data.type;
  }

  void _select(RequestType type) {
    setState(() => _selected = type);
    widget.data.type = type;
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

  Widget _buildProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الخطوة 1 من 4',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              Text(
                'نوع الطلب',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const LinearProgressIndicator(value: .25, minHeight: 6),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: widget.onBack,
            child: const Icon(Icons.close, size: 26, color: AppColors.textDark),
          ),
          const Spacer(),
          Text('إنشاء طلب', style: Theme.of(context).textTheme.headlineSmall),
          const Spacer(),
          const SizedBox(width: 26),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 8),
          Text(
            'ماذا تحتاج؟',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'اختر نوع الطلب الذي ترغب في نشره للمجتمع.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          _buildTypeOption(
            type: RequestType.needPlayers,
            isSelected: _selected == RequestType.needPlayers,
          ),
          const SizedBox(height: 14),
          _buildTypeOption(
            type: RequestType.lookingForOpponent,
            isSelected: _selected == RequestType.lookingForOpponent,
          ),
          const SizedBox(height: 14),
          _buildTypeOption(
            type: RequestType.pitchAvailable,
            isSelected: _selected == RequestType.pitchAvailable,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeOption({
    required RequestType type,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => _select(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withAlpha(25)
                    : AppColors.neutralSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                type.icon,
                size: 24,
                color: isSelected ? AppColors.primary : AppColors.textMuted,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type.label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    type.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Container(
                      margin: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _selected != null ? widget.onNext : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.border,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'التالي',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_back, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
