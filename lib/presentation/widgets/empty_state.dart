import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum EmptyStateType { noMatches, noHistory, loadError }

class EmptyState extends StatelessWidget {
  final EmptyStateType type;
  final VoidCallback? onAction;

  const EmptyState({super.key, required this.type, this.onAction});

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      EmptyStateType.noMatches => _buildNoMatches(context),
      EmptyStateType.noHistory => _buildNoHistory(context),
      EmptyStateType.loadError => _buildLoadError(context),
    };
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
            if (onAction != null)
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 52),
                child: ElevatedButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('إنشاء طلب'),
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

  Widget _buildNoHistory(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: const BoxDecoration(
              color: AppColors.neutralSurface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.history_toggle_off,
              size: 46,
              color: AppColors.neutralMuted,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'لا توجد مباريات سابقة بعد',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'ستظهر هنا المباريات التي نظّمتها أو شاركت فيها بعد انتهائها.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );

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
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: OutlinedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text('إعادة المحاولة'),
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
