import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum EmptyStateType { noMatches, loadError }

class EmptyState extends StatelessWidget {
  final EmptyStateType type;
  final VoidCallback? onAction;

  const EmptyState({super.key, required this.type, this.onAction});

  @override
  Widget build(BuildContext context) {
    return type == EmptyStateType.noMatches
        ? _buildNoMatches(context)
        : _buildLoadError(context);
  }

  Widget _buildNoMatches(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: AppColors.neutralSurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.sports_soccer_outlined,
                size: 50,
                color: AppColors.neutralMuted,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد مباريات متاحة حالياً',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'يبدو أنه لا توجد مباريات مجدولة في منطقتك حالياً. كن أول من ينظم مباراة!',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 60,
              child: ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add, size: 20),
                label: const Text(
                  'إنشاء طلب',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadError(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: AppColors.tertiarySurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 50,
                color: AppColors.tertiary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'تعذر تحميل المباريات',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text(
                  'إعادة المحاولة',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textDark,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
