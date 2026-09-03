import 'package:flutter/material.dart';

import '../../../data/models/user.dart';
import '../../theme/app_theme.dart';

/// Read-only profile shown for a match participant or organizer. It
/// deliberately receives a [User] object rather than an
/// id, so no technical identifier is rendered in the interface.
class PlayerProfileScreen extends StatelessWidget {
  final User player;

  const PlayerProfileScreen({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('الملف الشخصي')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _ProfileHeader(player: player),
              const SizedBox(height: 24),
              _InfoCard(
                icon: Icons.sports_soccer_outlined,
                label: 'المركز',
                value: player.position ?? 'غير محدد',
              ),
              _InfoCard(
                icon: Icons.trending_up_outlined,
                label: 'المستوى',
                value: _levelLabel(player.level),
              ),
              _InfoCard(
                icon: Icons.phone_outlined,
                label: 'رقم الهاتف',
                value: player.phoneNumber.isEmpty
                    ? 'غير متوفر'
                    : player.phoneNumber,
              ),
              _InfoCard(
                icon: Icons.star_outline,
                label: 'التقييم',
                value: player.ratingCount == 0
                    ? 'لا توجد تقييمات بعد'
                    : '${player.rating.toStringAsFixed(1)} من 5 (${player.ratingCount} تقييم)',
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _levelLabel(String? level) {
    switch (level) {
      case 'beginner':
        return 'مبتدئ';
      case 'intermediate':
        return 'متوسط';
      case 'advanced':
        return 'متقدم';
      default:
        return 'غير محدد';
    }
  }
}

class _ProfileHeader extends StatelessWidget {
  final User player;

  const _ProfileHeader({required this.player});

  @override
  Widget build(BuildContext context) {
    final initial = player.fullname.trim().isEmpty
        ? 'ل'
        : player.fullname.trim().characters.first;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor: AppColors.primarySurface,
            child: Text(
              initial,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            player.fullname,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          if (player.username.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              '@${player.username}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppColors.primarySurface,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 2),
              Text(value, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ],
    ),
  );
}
