import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_components.dart';

class MatchCard extends StatelessWidget {
  final String title;
  final String date;
  final String time;
  final String location;
  final String playersCount;
  final int? confirmedPlayers;
  final int? capacity;
  final String status;
  final String? description;
  final int? price;
  final String? organizerName;
  final double? organizerRating;
  final List<String> needs;
  final bool isFull;
  final VoidCallback? onTap;

  const MatchCard({
    super.key,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    required this.playersCount,
    required this.status,
    this.confirmedPlayers,
    this.capacity,
    this.description,
    this.price,
    this.organizerName,
    this.organizerRating,
    this.needs = const [],
    this.isFull = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusData = _statusData(status, isFull);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Semantics(
        button: true,
        label: 'عرض تفاصيل $title في $location يوم $date على الساعة $time',
        child: AppSurfaceCard(
          padding: EdgeInsets.zero,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, statusData),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _MetaLine(
                              icon: Icons.calendar_today_outlined,
                              text: date,
                            ),
                          ),
                          const SizedBox(width: 12),
                          _MetaLine(
                            icon: Icons.schedule_rounded,
                            text: time,
                            emphasized: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _MetaLine(
                        icon: Icons.location_on_outlined,
                        text: location,
                        expanded: true,
                      ),
                      if (confirmedPlayers != null && capacity != null) ...[
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: SquadMeter(
                                confirmed: confirmedPlayers!,
                                capacity: capacity!,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '$confirmedPlayers/$capacity لاعب',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(color: AppColors.slate),
                            ),
                          ],
                        ),
                      ],
                      if (needs.isNotEmpty || price != null) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 7,
                          runSpacing: 7,
                          children: [
                            if (price != null)
                              _Tag(
                                icon: Icons.payments_outlined,
                                text: '$price دج',
                                color: AppColors.slate,
                              ),
                            ...needs.map(
                              (need) => _Tag(icon: _needIcon(need), text: need),
                            ),
                          ],
                        ),
                      ],
                      if (description?.trim().isNotEmpty ?? false) ...[
                        const SizedBox(height: 12),
                        Text(
                          description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 17,
                            backgroundColor: AppColors.primarySurface,
                            child: Text(
                              _initials(organizerName),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  organizerName ?? 'منظّم المباراة',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                                if (organizerRating != null)
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star_rounded,
                                        size: 14,
                                        color: AppColors.warning,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        organizerRating == 0
                                            ? 'منظّم جديد'
                                            : organizerRating!.toStringAsFixed(
                                                1,
                                              ),
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            'عرض التفاصيل',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(color: AppColors.primary),
                          ),
                          const SizedBox(width: 3),
                          const Icon(
                            Icons.chevron_left_rounded,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, _StatusData statusData) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.sports_soccer, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (confirmedPlayers == null)
                  Text(
                    playersCount,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          AppStatusPill(
            label: statusData.label,
            tone: statusData.tone,
            icon: statusData.icon,
          ),
        ],
      ),
    );
  }

  static String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return 'م';
    final words = name.trim().split(RegExp(r'\s+'));
    return words.take(2).map((word) => word[0]).join();
  }

  static IconData _needIcon(String need) {
    if (need.contains('كرة')) return Icons.sports_soccer;
    if (need.contains('مضخة')) return Icons.air;
    if (need.contains('خصم')) return Icons.groups_2_outlined;
    return Icons.person_add_alt_1_outlined;
  }

  static _StatusData _statusData(String value, bool full) {
    if (full) {
      return const _StatusData(
        'مكتملة',
        AppStatusTone.neutral,
        Icons.group_rounded,
      );
    }
    switch (value) {
      case 'cancelled':
        return const _StatusData(
          'ملغاة',
          AppStatusTone.danger,
          Icons.cancel_outlined,
        );
      case 'finished':
        return const _StatusData(
          'منتهية',
          AppStatusTone.neutral,
          Icons.flag_outlined,
        );
      case 'inProgress':
      case 'in_progress':
        return const _StatusData(
          'جارية',
          AppStatusTone.warning,
          Icons.sports_soccer,
        );
      default:
        return const _StatusData(
          'متاحة',
          AppStatusTone.success,
          Icons.bolt_rounded,
        );
    }
  }
}

class _StatusData {
  final String label;
  final AppStatusTone tone;
  final IconData icon;

  const _StatusData(this.label, this.tone, this.icon);
}

class _MetaLine extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool emphasized;
  final bool expanded;

  const _MetaLine({
    required this.icon,
    required this.text,
    this.emphasized = false,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: emphasized ? AppColors.ink : AppColors.slate,
              fontWeight: emphasized ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
    return expanded
        ? SizedBox(width: double.infinity, child: content)
        : content;
  }
}

class _Tag extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _Tag({
    required this.icon,
    required this.text,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: color.withAlpha(20),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            height: 1.4,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    ),
  );
}
