import 'package:flutter/material.dart';
import '../../../data/models/game.dart';
import '../../../data/models/pitch.dart';
import '../../../data/models/user.dart';
import '../../../main.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/match_card.dart';
import '../../widgets/app_components.dart';
import '../request/create_request_screen.dart';
import 'match_details.dart';

/// Searchable public catalogue. Personal activity is intentionally kept on Home.
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List<Game> _games = [];
  List<Pitch> _pitches = [];
  Map<int, int> _accepted = {};
  Map<int, Set<String>> _needs = {};
  Map<String, User> _organizers = {};
  DateTime? _date;
  int? _pitchId;
  String? _need;
  String _query = '';
  bool _availableOnly = true;
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
      final results = await Future.wait([
        appData.games(from: DateTime.now()),
        appData.pitches(),
      ]);
      final games = results[0] as List<Game>;
      final countsFuture = appData.acceptedRequestCounts(
        games.map((g) => g.id),
      );
      final needsFuture = appData.gameNeedNamesForGames(games.map((g) => g.id));
      Map<String, User> organizers = {};
      try {
        organizers = await appData.fetchProfiles(games.map((g) => g.userId));
      } catch (_) {}
      final counts = await countsFuture;
      final needs = await needsFuture;
      if (!mounted) return;
      setState(() {
        _games = games;
        _pitches = results[1] as List<Pitch>;
        _accepted = counts;
        _needs = needs;
        _organizers = organizers;
      });
    } catch (_) {
      if (mounted) setState(() => _error = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Game> get _filtered => _games.where((game) {
    if (game.status == GameStatus.cancelled ||
        game.status == GameStatus.finished) {
      return false;
    }
    final accepted = _accepted[game.id] ?? 0;
    if (_availableOnly &&
        (game.status != GameStatus.pending || accepted >= game.maxPlayers)) {
      return false;
    }
    if (_date != null && !DateUtils.isSameDay(game.startingTime, _date)) {
      return false;
    }
    if (_pitchId != null && game.pitchId != _pitchId) return false;
    if (_need != null && !(_needs[game.id] ?? {}).contains(_need)) return false;
    final query = _query.trim().toLowerCase();
    if (query.isNotEmpty) {
      final pitchName = _pitch(game.pitchId)?.name.toLowerCase() ?? '';
      final organizer = _organizers[game.userId]?.fullname.toLowerCase() ?? '';
      final title = game.title?.toLowerCase() ?? '';
      if (!title.contains(query) &&
          !pitchName.contains(query) &&
          !organizer.contains(query)) {
        return false;
      }
    }
    return true;
  }).toList();

  Pitch? _pitch(int id) {
    for (final pitch in _pitches) {
      if (pitch.id == id) return pitch;
    }
    return null;
  }

  int get _activeFilters =>
      (_date != null ? 1 : 0) +
      (_pitchId != null ? 1 : 0) +
      (_need != null ? 1 : 0) +
      (!_availableOnly ? 1 : 0);

  void _resetFilters() => setState(() {
    _date = null;
    _pitchId = null;
    _need = null;
    _availableOnly = true;
  });

  Future<void> _showFilters() async {
    final result = await showModalBottomSheet<_ExploreFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(
        initial: _ExploreFilter(
          date: _date,
          pitchId: _pitchId,
          need: _need,
          availableOnly: _availableOnly,
        ),
        pitches: _pitches,
      ),
    );
    if (result == null) return;
    setState(() {
      _date = result.date;
      _pitchId = result.pitchId;
      _need = result.need;
      _availableOnly = result.availableOnly;
    });
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Column(
      children: [
        AppTopBar(
          title: 'اكتشف المباريات',
          subtitle: 'اعثر على المباراة المناسبة لك',
          leading: IconButton.filledTonal(
            tooltip: 'إنشاء مباراة',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateRequestScreen()),
            ),
            icon: const Icon(Icons.add),
          ),
          trailing: Badge(
            isLabelVisible: _activeFilters > 0,
            label: Text('$_activeFilters'),
            child: IconButton(
              tooltip: 'تصفية المباريات',
              onPressed: _showFilters,
              icon: const Icon(Icons.tune_rounded),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
          child: TextField(
            onChanged: (value) => setState(() => _query = value),
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              hintText: 'ابحث بعنوان المباراة، الملعب أو المنظّم',
              prefixIcon: Icon(Icons.search_rounded),
              suffixIcon: Icon(Icons.sports_soccer_outlined),
            ),
          ),
        ),
        if (!_loading && !_error)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  '${_filtered.length} مباراة',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const Spacer(),
                if (_activeFilters > 0)
                  TextButton.icon(
                    onPressed: _resetFilters,
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('مسح الفلاتر'),
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
    final games = _filtered;
    if (games.isEmpty) {
      return EmptyState(
        type: EmptyStateType.noMatches,
        onAction: _activeFilters > 0 ? _resetFilters : null,
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 4, bottom: 18),
        itemCount: games.length,
        itemBuilder: (_, index) {
          final game = games[index];
          final pitch = _pitch(game.pitchId);
          final count = _accepted[game.id] ?? 0;
          final organizer = _organizers[game.userId];
          return MatchCard(
            title: game.title ?? 'مباراة ودية',
            date:
                '${game.startingTime.day}/${game.startingTime.month}/${game.startingTime.year}',
            time: _time(game.startingTime),
            location: pitch?.name ?? 'ملعب غير متاح',
            playersCount: '$count/${game.maxPlayers}',
            confirmedPlayers: count,
            capacity: game.maxPlayers,
            status: game.status.name,
            isFull:
                count >= game.maxPlayers || game.status != GameStatus.pending,
            price: game.price,
            organizerName: organizer?.fullname,
            organizerRating: organizer?.rating,
            needs: _sortedNeeds(_needs[game.id] ?? {}),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MatchDetailsScreen(gameId: game.id),
              ),
            ),
          );
        },
      ),
    );
  }

  String _time(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

  List<String> _sortedNeeds(Set<String> values) {
    const priority = {
      'players': 0,
      'opponent': 0,
      'pitch_available': 0,
      'football': 1,
      'pump': 2,
      'lighting': 3,
    };
    final sorted = values.toList()
      ..sort((a, b) => (priority[a] ?? 9).compareTo(priority[b] ?? 9));
    return sorted.map(_needLabel).toList();
  }
}

String _needLabel(String value) =>
    const {
      'players': 'لاعبون',
      'opponent': 'خصم',
      'football': 'كرة',
      'pump': 'مضخة',
      'lighting': 'مضخة',
      'pitch_available': 'ملعب متاح',
    }[value] ??
    value;

class _ExploreFilter {
  final DateTime? date;
  final int? pitchId;
  final String? need;
  final bool availableOnly;
  const _ExploreFilter({
    this.date,
    this.pitchId,
    this.need,
    required this.availableOnly,
  });
}

class _FilterSheet extends StatefulWidget {
  final _ExploreFilter initial;
  final List<Pitch> pitches;
  const _FilterSheet({required this.initial, required this.pitches});
  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late DateTime? date = widget.initial.date;
  late int? pitchId = widget.initial.pitchId;
  late String? need = widget.initial.need;
  late bool availableOnly = widget.initial.availableOnly;

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .82,
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        20 + MediaQuery.viewPaddingOf(context).bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'تصفية النتائج',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            Text('التاريخ', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('أي يوم'),
                  selected: date == null,
                  onSelected: (_) => setState(() => date = null),
                ),
                ChoiceChip(
                  label: const Text('اليوم'),
                  selected:
                      date != null && DateUtils.isSameDay(date, DateTime.now()),
                  onSelected: (_) => setState(() => date = DateTime.now()),
                ),
                ChoiceChip(
                  label: const Text('غداً'),
                  selected:
                      date != null &&
                      DateUtils.isSameDay(
                        date,
                        DateTime.now().add(const Duration(days: 1)),
                      ),
                  onSelected: (_) => setState(
                    () => date = DateTime.now().add(const Duration(days: 1)),
                  ),
                ),
                ActionChip(
                  avatar: const Icon(Icons.calendar_month, size: 16),
                  label: Text(
                    date == null ? 'تاريخ محدد' : '${date!.day}/${date!.month}',
                  ),
                  onPressed: () async {
                    final value = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 180)),
                      initialDate: date ?? DateTime.now(),
                    );
                    if (value != null) setState(() => date = value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<int?>(
              initialValue: pitchId,
              decoration: const InputDecoration(
                labelText: 'الملعب',
                prefixIcon: Icon(Icons.stadium_outlined),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('كل الملاعب')),
                ...widget.pitches.map(
                  (p) => DropdownMenuItem(value: p.id, child: Text(p.name)),
                ),
              ],
              onChanged: (value) => setState(() => pitchId = value),
            ),
            const SizedBox(height: 20),
            Text('نوع الاحتياج', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  ['players', 'opponent', 'football', 'pump', 'pitch_available']
                      .map(
                        (item) => ChoiceChip(
                          label: Text(_needLabel(item)),
                          selected: need == item,
                          onSelected: (selected) =>
                              setState(() => need = selected ? item : null),
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 10),
            Material(
              color: Colors.transparent,
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('المباريات المتاحة فقط'),
                subtitle: const Text('إخفاء المكتملة والملغاة'),
                value: availableOnly,
                onChanged: (value) => setState(() => availableOnly = value),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() {
                      date = null;
                      pitchId = null;
                      need = null;
                      availableOnly = true;
                    }),
                    child: const Text('إعادة الضبط'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(
                      context,
                      _ExploreFilter(
                        date: date,
                        pitchId: pitchId,
                        need: need,
                        availableOnly: availableOnly,
                      ),
                    ),
                    child: const Text('عرض النتائج'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
