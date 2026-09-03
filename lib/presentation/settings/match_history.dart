import 'package:flutter/material.dart';

import '../../data/models/game.dart';
import '../../main.dart';
import '../theme/app_theme.dart';

class MatchHistoryScreen extends StatefulWidget {
  const MatchHistoryScreen({super.key});

  @override
  State<MatchHistoryScreen> createState() => _MatchHistoryScreenState();
}

class _MatchHistoryScreenState extends State<MatchHistoryScreen> {
  List<Game> _games = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final games = await appData.games();
      if (mounted) {
        setState(
          () => _games = games
              .where(
                (game) =>
                    game.endingTime.isBefore(DateTime.now()) ||
                    game.status == GameStatus.finished,
              )
              .toList(),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      appBar: AppBar(title: const Text('سجل المباريات')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _games.isEmpty
          ? const _HistoryEmpty()
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _games.length,
                itemBuilder: (context, index) {
                  final game = _games[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.primarySurface,
                        child: Icon(
                          Icons.sports_soccer,
                          color: AppColors.primary,
                        ),
                      ),
                      title: Text(game.title ?? 'مباراة'),
                      subtitle: Text(
                        '${game.startingTime.day}/${game.startingTime.month}/${game.startingTime.year} · ملعب ${game.pitchId}',
                      ),
                      trailing: const Icon(Icons.chevron_left),
                    ),
                  );
                },
              ),
            ),
    ),
  );
}

class _HistoryEmpty extends StatelessWidget {
  const _HistoryEmpty();
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.history_toggle_off,
          size: 56,
          color: AppColors.placeholder,
        ),
        const SizedBox(height: 12),
        Text(
          'لا توجد مباريات سابقة بعد',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    ),
  );
}
