import 'package:flutter/material.dart';
import '../../../data/models/reservation.dart';
import '../../../data/models/game.dart';
import '../../../main.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/match_card.dart';
import '../discover/match_details.dart';
import '../request/create_request_screen.dart';
import '../../settings/settings_screen.dart';

/// Personal dashboard: upcoming activity, numbers and quick actions.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Reservation> _organized = [];
  List<Reservation> _joined = [];
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final result = await Future.wait([
        appData.myOrganizedGames(),
        appData.myJoinedGames(),
      ]);
      if (mounted) {
        setState(() {
          _organized = result[0];
          _joined = result[1];
        });
      }
    } catch (_) {
      if (mounted) setState(() => _error = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Reservation> get _upcoming {
    final values = [..._organized, ..._joined]
        .where(
          (item) =>
              item.game.startingTime.isAfter(DateTime.now()) &&
              item.game.status != GameStatus.cancelled &&
              item.game.status != GameStatus.finished,
        )
        .toList();
    values.sort((a, b) => a.game.startingTime.compareTo(b.game.startingTime));
    return values;
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              IconButton.filledTonal(
                tooltip: 'إنشاء مباراة',
                onPressed: _create,
                icon: const Icon(Icons.add),
              ),
              const Spacer(),
              Text(
                'Créneau Médea',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Spacer(),
              IconButton(
                tooltip: 'الإعدادات',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
        ),
        Expanded(child: _body()),
      ],
    ),
  );

  Widget _body() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error) {
      return EmptyState(type: EmptyStateType.loadError, onAction: _load);
    }
    final user = authService.currentUser;
    final next = _upcoming.isEmpty ? null : _upcoming.first;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(20, 6, 20, 20),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withAlpha(205)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(42),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مرحباً، ${user?.fullname.split(' ').first ?? 'لاعب'}',
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        next == null
                            ? 'أنشئ مباراتك الأولى وابدأ اللعب'
                            : _upcomingPhrase(_upcoming.length),
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 18),
                      FilledButton.tonalIcon(
                        onPressed: _create,
                        icon: const Icon(Icons.add),
                        label: const Text('أنشئ مباراة'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.sports_soccer_rounded,
                  size: 74,
                  color: Colors.white24,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _Stat(
                    icon: Icons.event_available,
                    value: '${_organized.length}',
                    label: 'نظّمتها',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _Stat(
                    icon: Icons.directions_run,
                    value: '${_joined.length}',
                    label: 'انضممت إليها',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _Stat(
                    icon: Icons.star_rounded,
                    value: user?.rating == 0
                        ? 'جديد'
                        : user!.rating.toStringAsFixed(1),
                    label: 'تقييمك',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'مباراتك القادمة',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 8),
          if (next == null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'لا توجد مباراة قادمة. استخدم صفحة اكتشف للعثور على مباراة مناسبة.',
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            MatchCard(
              title: next.game.title ?? 'مباراة ودية',
              date:
                  '${next.game.startingTime.day}/${next.game.startingTime.month}/${next.game.startingTime.year}',
              time: _time(next.game.startingTime),
              location: next.pitch?.name ?? 'تفاصيل الملعب',
              playersCount:
                  next.request.userId == user?.id &&
                      _organized.any((r) => r.game.id == next.game.id)
                  ? 'منظّم'
                  : 'مؤكد',
              status: next.game.status.name,
              price: next.game.price,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MatchDetailsScreen(gameId: next.game.id),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _create() => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const CreateRequestScreen()),
  ).then((_) => _load());
  String _time(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

  String _upcomingPhrase(int count) {
    if (count == 1) return 'لديك مباراة قادمة';
    if (count == 2) return 'لديك مبارتين قادمتين';
    if (count >= 3 && count <= 10) return 'لديك $count مباريات قادمة';
    return 'لديك $count مباراة قادمة';
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _Stat({required this.icon, required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(height: 7),
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ),
  );
}
