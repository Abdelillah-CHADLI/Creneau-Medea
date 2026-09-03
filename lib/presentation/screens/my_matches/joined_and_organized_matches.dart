import 'package:flutter/material.dart';
import '../../../data/models/game.dart';
import '../../../data/models/reservation.dart';
import '../../../data/models/request.dart';
import '../../../main.dart';
import '../../theme/app_theme.dart';
import '../discover/match_details.dart';
import 'match_management.dart';
import 'edit_organized_matches.dart';
import 'archived_matches.dart';
import '../../widgets/cancellation_dialog.dart';

class MyMatchesScreen extends StatefulWidget {
  const MyMatchesScreen({super.key});

  @override
  State<MyMatchesScreen> createState() => _MyMatchesScreenState();
}

class _MyMatchesScreenState extends State<MyMatchesScreen> {
  bool _isOrganizing = true;
  bool _loading = true;
  bool _error = false;
  List<Reservation> _organized = [];
  List<Reservation> _joined = [];

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
        appData.myOrganizedGames(),
        appData.myJoinedGames(),
      ]);
      if (mounted) {
        setState(() {
          _organized = results[0];
          _joined = results[1];
        });
      }
    } catch (_) {
      if (mounted) setState(() => _error = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openManagement(int gameId) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MatchManagementScreen(gameId: gameId)),
    );
  }

  void _openDetails(int gameId) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MatchDetailsScreen(gameId: gameId)),
    );
  }

  Future<void> _editGame(Game game) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => EditOrganizedMatchScreen(game: game)),
    );
    if (changed == true) _load();
  }

  Future<void> _cancelGame(Game game) async {
    CancellationDialog.show(
      context,
      onConfirm: () async {
        try {
          await appData.cancelGame(game.id);
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('تم إلغاء المباراة')));
            _load();
          }
        } catch (error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('تعذر إلغاء المباراة: $error')),
            );
          }
        }
      },
    );
  }

  Future<void> _finishGame(Game game) async {
    try {
      await appData.updateGame(game.id, status: GameStatus.finished);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إنهاء المباراة. يمكنك الآن تقييم اللاعبين.'),
          ),
        );
        _load();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('تعذر إنهاء المباراة: $error')));
      }
    }
  }

  Future<void> _archive(Reservation item, bool organized) async {
    try {
      if (organized) {
        await appData.setOrganizedGameArchived(item.game.id, true);
      } else {
        await appData.setJoinedGameArchived(item.request.id, true);
      }
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تمت أرشفة المباراة دون حذفها'),
          action: SnackBarAction(
            label: 'تراجع',
            onPressed: () async {
              if (organized) {
                await appData.setOrganizedGameArchived(item.game.id, false);
              } else {
                await appData.setJoinedGameArchived(item.request.id, false);
              }
              await _load();
            },
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('تعذر أرشفة المباراة: $error')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border.symmetric(
          vertical: BorderSide(color: AppColors.accent, width: 2),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildToggleTabs(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          IconButton(
            tooltip: 'المباريات المؤرشفة',
            onPressed: () => Navigator.of(context)
                .push(
                  MaterialPageRoute(
                    builder: (_) => const ArchivedMatchesScreen(),
                  ),
                )
                .then((_) => _load()),
            icon: const Icon(
              Icons.inventory_2_outlined,
              color: AppColors.textDark,
            ),
          ),
          const Spacer(),
          Text(
            'Créneau Médea',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const Spacer(),
          const SizedBox(width: 38),
        ],
      ),
    );
  }

  Widget _buildToggleTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.neutralSurface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isOrganizing = true),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _isOrganizing
                        ? AppColors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'أنظمها',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _isOrganizing ? Colors.white : AppColors.textDark,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isOrganizing = false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: !_isOrganizing
                        ? AppColors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'انضممت إليها',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: !_isOrganizing ? Colors.white : AppColors.textDark,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('تعذر تحميل مبارياتك'),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _load,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }
    final list = _isOrganizing ? _organized : _joined;
    if (list.isEmpty) {
      return Center(
        child: Text(
          _isOrganizing ? 'لا توجد مباريات تنظمها' : 'لم تنضم لأي مباراة بعد',
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          if (_isOrganizing)
            ...list.map((r) => _buildOrganizedCard(context, r))
          else
            ...list.map((r) => _buildJoinedCard(context, r)),
        ],
      ),
    );
  }

  Widget _buildOrganizedCard(BuildContext context, Reservation r) {
    final game = r.game;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _openDetails(game.id),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    game.title ?? 'مباراة',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                _statusBadge(game.status),
                IconButton(
                  tooltip: 'أرشفة المباراة',
                  onPressed: () => _archive(r, true),
                  icon: const Icon(
                    Icons.archive_outlined,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 16,
                color: AppColors.neutralMuted,
              ),
              const SizedBox(width: 6),
              Text(
                _formatTime(game.startingTime),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.neutralMuted,
              ),
              const SizedBox(width: 6),
              Text(
                _pitchName(r),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (game.status == GameStatus.pending) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _editGame(game),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('تعديل'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _cancelGame(game),
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('إلغاء'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.tertiary,
                      side: const BorderSide(color: AppColors.tertiary),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          if (game.status == GameStatus.inProgress ||
              game.status == GameStatus.pending) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _finishGame(game),
                icon: const Icon(Icons.flag_outlined),
                label: const Text('إنهاء المباراة'),
              ),
            ),
            const SizedBox(height: 10),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openManagement(game.id),
              icon: const Icon(Icons.people_outline, size: 20),
              label: const Text('إدارة اللاعبين'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinedCard(BuildContext context, Reservation r) {
    final game = r.game;
    return GestureDetector(
      onTap: () => _openDetails(game.id),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.all(16),
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
                    game.title ?? 'مباراة',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                _statusBadge(game.status),
                IconButton(
                  tooltip: 'أرشفة المباراة',
                  onPressed: () => _archive(r, false),
                  icon: const Icon(
                    Icons.archive_outlined,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.neutralMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  _formatTime(game.startingTime),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppColors.neutralMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  _pitchName(r),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _attendanceBadge(r),
          ],
        ),
      ),
    );
  }

  Widget _attendanceBadge(Reservation reservation) {
    final attendance = reservation.request.attendance;
    final label = attendance == AttendanceStatus.attended
        ? 'تم تسجيلك حاضراً'
        : attendance == AttendanceStatus.absent
        ? 'تم تسجيلك غائباً'
        : 'لم يُسجّل الحضور بعد';
    final color = attendance == AttendanceStatus.attended
        ? AppColors.primary
        : attendance == AttendanceStatus.absent
        ? AppColors.tertiary
        : AppColors.secondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.how_to_reg_outlined, size: 16, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(GameStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status == GameStatus.cancelled
            ? AppColors.tertiarySurface
            : AppColors.primarySurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _statusLabel(status),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: status == GameStatus.cancelled
              ? AppColors.tertiary
              : AppColors.primary,
        ),
      ),
    );
  }

  String _statusLabel(GameStatus s) {
    switch (s) {
      case GameStatus.pending:
        return 'قيد الانتظار';
      case GameStatus.inProgress:
        return 'جارية';
      case GameStatus.finished:
        return 'منتهية';
      case GameStatus.cancelled:
        return 'ملغاة';
    }
  }

  String _pitchName(Reservation r) => r.pitch?.name ?? 'ملعب ${r.game.pitchId}';

  String _formatTime(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
