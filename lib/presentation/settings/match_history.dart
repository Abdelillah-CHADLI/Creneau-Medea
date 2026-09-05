import 'package:flutter/material.dart';

import '../../data/models/game.dart';
import '../../data/models/reservation.dart';
import '../../main.dart';
import '../screens/discover/match_details.dart';
import '../theme/app_theme.dart';
import '../widgets/app_components.dart';
import '../widgets/empty_state.dart';

class MatchHistoryScreen extends StatefulWidget {
  const MatchHistoryScreen({super.key});

  @override
  State<MatchHistoryScreen> createState() => _MatchHistoryScreenState();
}

class _MatchHistoryScreenState extends State<MatchHistoryScreen> {
  List<Reservation> _matches = [];
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
      final groups = await Future.wait([
        appData.myOrganizedGames(),
        appData.myOrganizedGames(archived: true),
        appData.myJoinedGames(),
        appData.myJoinedGames(archived: true),
      ]);
      final byGame = <int, Reservation>{};
      for (final item in groups.expand((group) => group)) {
        final game = item.game;
        final isPast =
            game.endingTime.isBefore(DateTime.now()) ||
            game.status == GameStatus.finished ||
            game.status == GameStatus.cancelled;
        if (isPast) byGame[game.id] = item;
      }
      final matches = byGame.values.toList()
        ..sort((a, b) => b.game.startingTime.compareTo(a.game.startingTime));
      if (mounted) setState(() => _matches = matches);
    } catch (_) {
      if (mounted) setState(() => _error = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(
              title: 'سجل المباريات',
              subtitle: 'المباريات التي نظّمتها أو شاركت فيها',
              showLogo: false,
              leading: IconButton(
                tooltip: 'رجوع',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_forward_ios, size: 20),
              ),
            ),
            Expanded(child: _body()),
          ],
        ),
      ),
    ),
  );

  Widget _body() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error) {
      return EmptyState(type: EmptyStateType.loadError, onAction: _load);
    }
    if (_matches.isEmpty) return const _HistoryEmpty();
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        itemCount: _matches.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = _matches[index];
          final game = item.game;
          final cancelled = game.status == GameStatus.cancelled;
          return AppSurfaceCard(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MatchDetailsScreen(gameId: game.id),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: cancelled
                        ? AppColors.tertiarySurface
                        : AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    cancelled ? Icons.event_busy_outlined : Icons.sports_soccer,
                    color: cancelled ? AppColors.tertiary : AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        game.title ?? 'مباراة',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${_date(game.startingTime)} · ${item.pitch?.name ?? 'ملعب غير متاح'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                AppStatusPill(
                  label: cancelled ? 'ملغاة' : 'منتهية',
                  tone: cancelled
                      ? AppStatusTone.danger
                      : AppStatusTone.neutral,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _date(DateTime date) =>
      '${date.day}/${date.month}/${date.year} · ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

class _HistoryEmpty extends StatelessWidget {
  const _HistoryEmpty();

  @override
  Widget build(BuildContext context) =>
      const Center(child: EmptyState(type: EmptyStateType.noHistory));
}
