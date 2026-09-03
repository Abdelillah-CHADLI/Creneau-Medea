import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'create_request_data.dart';

class ConfirmRequestStep extends StatelessWidget {
  final CreateRequestData data;
  final VoidCallback onPublish;
  final VoidCallback onBack;

  const ConfirmRequestStep({
    super.key,
    required this.data,
    required this.onPublish,
    required this.onBack,
  });

  String _formatTime(TimeOfDay? t) {
    if (t == null) return '--:--';
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'صباحاً' : 'مساءً';
    return '$h:$m $period';
  }

  String _formatDate(DateTime d) {
    const months = [
      '',
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    const weekdays = [
      '',
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    return '${weekdays[d.weekday]}, ${d.day} ${months[d.month]}';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          _buildHeader(context),
          _buildProgress(context),
          Expanded(child: _buildBody(context)),
          _buildBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: const Icon(
              Icons.arrow_forward_ios,
              size: 22,
              color: AppColors.textDark,
            ),
          ),
          const Spacer(),
          Text(
            'مراجعة الطلب',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const Spacer(),
          const SizedBox(width: 26),
        ],
      ),
    );
  }

  Widget _buildProgress(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الخطوة 4 من 4',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              Text(
                'المراجعة والنشر',
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
              value: 1.0,
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

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Text(
            'معاينة المباراة',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'هكذا سيظهر طلبك لللاعبين الآخرين.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildPreviewCard(context),
        ],
      ),
    );
  }

  Widget _buildPreviewCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  data.title?.trim().isNotEmpty == true
                      ? data.title!.trim()
                      : 'طلب مباراة',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      data.type?.icon ?? Icons.sports_soccer,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _purposeLabel(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.warning.withAlpha(25),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'قيد الانتظار',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.warning,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              _InfoChip(
                icon: Icons.calendar_today_outlined,
                text: _formatDate(data.date ?? DateTime.now()),
              ),
              const SizedBox(width: 16),
              _InfoChip(
                icon: Icons.access_time,
                text: _formatTime(data.startTime),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _InfoChip(
                icon: Icons.location_on_outlined,
                text: data.pitchName ?? 'ملعب غير محدد',
              ),
              const SizedBox(width: 16),
              _InfoChip(
                icon: Icons.payments_outlined,
                text: data.price == null
                    ? 'حسب اتفاق الفريق'
                    : '${data.price} دج / لاعب',
              ),
            ],
          ),
          if (data.notes != null && data.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Text(
              data.notes!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted,
                height: 1.6,
              ),
            ),
          ],
          if (data.equipment.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: data.equipment.map((eq) {
                const labels = {
                  'players': 'نحتاج لاعبين',
                  'opponent': 'نبحث عن خصم',
                  'football': 'كرة مطلوبة',
                  'lighting': 'إضاءة مطلوبة',
                  'pump': 'مضخة مطلوبة',
                };
                const icons = {
                  'players': Icons.people_outline,
                  'opponent': Icons.sports_mma_outlined,
                  'football': Icons.sports_soccer,
                  'lighting': Icons.lightbulb_outline,
                  'pump': Icons.air,
                };
                final label = labels[eq] ?? eq;
                final icon = icons[eq] ?? Icons.check_circle_outline;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  String _purposeLabel() {
    switch (data.type) {
      case RequestType.needPlayers:
        final count = data.playerCount ?? 1;
        return count == 1 ? 'نحتاج لاعباً' : 'نحتاج $count لاعبين';
      case RequestType.lookingForOpponent:
        return 'نبحث عن خصم';
      case RequestType.pitchAvailable:
        return 'ملعب متاح';
      case null:
        return 'طلب مباراة';
    }
  }

  Widget _buildBottomBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: onPublish,
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
              Icon(Icons.send, size: 22),
              SizedBox(width: 8),
              Text(
                'نشر الطلب',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}
