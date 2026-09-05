import 'package:flutter/material.dart';
import '../../../data/models/request.dart';
import '../../../data/models/user.dart';
import '../../../data/models/game.dart';
import '../../../data/models/player_rating.dart';
import '../../../main.dart';
import '../../theme/app_theme.dart';
import 'player_profile.dart';
import '../../widgets/app_components.dart';

class MatchManagementScreen extends StatefulWidget {
  final int gameId;

  const MatchManagementScreen({super.key, required this.gameId});

  @override
  State<MatchManagementScreen> createState() => _MatchManagementScreenState();
}

class _MatchManagementScreenState extends State<MatchManagementScreen> {
  List<Request> _requests = [];
  Map<String, User> _players = {};
  Game? _game;
  Map<int, PlayerRating> _ratings = {};
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
        appData.requestsForGame(widget.gameId),
        appData.gameById(widget.gameId),
        appData.ratingsForGame(widget.gameId),
      ]);
      final requests = results[0] as List<Request>;
      Map<String, User> players = {};
      try {
        players = await appData.fetchProfiles(requests.map((r) => r.userId));
      } catch (_) {
        // The requests remain usable even if a legacy profile is unavailable.
      }
      if (mounted) {
        setState(() {
          _requests = requests;
          _players = players;
          _game = results[1] as Game?;
          _ratings = {
            for (final rating in results[2] as List<PlayerRating>)
              rating.gameRequestId: rating,
          };
        });
      }
    } catch (_) {
      if (mounted) setState(() => _error = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _respond(Request r, String status) async {
    try {
      await appData.respondToRequest(r.id, status);
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشلت العملية: $e')));
    }
  }

  Future<void> _chooseAttendance(Request r) async {
    final value = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تسجيل حضور اللاعب',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                  ),
                  title: const Text('حاضر'),
                  onTap: () => Navigator.pop(context, 'attended'),
                ),
                ListTile(
                  leading: const Icon(Icons.cancel, color: AppColors.tertiary),
                  title: const Text('غائب'),
                  onTap: () => Navigator.pop(context, 'absent'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (value == null) return;
    try {
      await appData.setAttendance(r.id, value);
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشلت العملية: $e')));
    }
  }

  Future<void> _rate(Request request, User? player) async {
    if (player == null) return;
    if (_ratings.containsKey(request.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تقييم هذا اللاعب بالفعل')),
      );
      return;
    }
    var score = 5;
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 22),
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: AppColors.primarySurface,
                    child: Text(
                      player.fullname.characters.first,
                      style: const TextStyle(
                        fontSize: 24,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'كيف كان أداء ${player.fullname}؟',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _ratingLabel(score),
                    style: const TextStyle(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (index) => IconButton(
                        iconSize: 40,
                        tooltip: '${index + 1} نجوم',
                        onPressed: () => setSheetState(() => score = index + 1),
                        icon: Icon(
                          index < score
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warningSurface,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$score من 5 · ${_ratingLabel(score)}',
                      style: const TextStyle(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 52),
                      child: FilledButton.icon(
                        onPressed: () => Navigator.pop(context, true),
                        icon: const Icon(Icons.check),
                        label: const Text('حفظ التقييم'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إلغاء'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await appData.ratePlayer(
        gameRequestId: request.id,
        gameId: request.gameId,
        playerId: player.id,
        organizerId: authService.currentUser!.id,
        rating: score,
      );
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم حفظ التقييم')));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('تعذر حفظ التقييم: $error')));
      }
    }
  }

  String _ratingLabel(int value) =>
      const ['', 'ضعيف', 'مقبول', 'جيد', 'جيد جداً', 'ممتاز'][value];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(child: _buildBody(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return AppTopBar(
      title: 'إدارة اللاعبين',
      subtitle: _game?.title,
      showLogo: false,
      leading: IconButton(
        tooltip: 'رجوع',
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_forward_ios, size: 20),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('تعذر تحميل الطلبات'),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _load,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    final pending = _requests
        .where((r) => r.status == RequestStatus.pending)
        .toList();
    final accepted = _requests
        .where((r) => r.status == RequestStatus.accepted)
        .toList();

    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMatchSummary(context),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'قيد الانتظار (${pending.length})'),
            const SizedBox(height: 12),
            if (pending.isEmpty)
              _buildEmptyHint(context, 'لا توجد طلبات قيد الانتظار')
            else
              ...pending.map(
                (r) => _buildPendingPlayer(context, r, _players[r.userId]),
              ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'تم التأكيد (${accepted.length})'),
            const SizedBox(height: 12),
            if (accepted.isEmpty)
              _buildEmptyHint(context, 'لا يوجد لاعبون مؤكدون بعد')
            else
              ...accepted.map(
                (r) => _buildConfirmedPlayer(context, r, _players[r.userId]),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyHint(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
    );
  }

  Widget _buildMatchSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.neutralSurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${_requests.length} طلب',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
          const Spacer(),
          Text(
            _game?.title ?? 'المباراة',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }

  Widget _buildPendingPlayer(BuildContext context, Request r, User? player) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _buildActionButton(
            icon: Icons.close,
            color: AppColors.tertiary,
            backgroundColor: AppColors.tertiarySurface,
            onTap: () => _respond(r, 'rejected'),
          ),
          const SizedBox(width: 10),
          _buildActionButton(
            icon: Icons.check,
            color: AppColors.primary,
            backgroundColor: AppColors.primarySurface,
            onTap: () => _respond(r, 'accepted'),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _playerName(player),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
            ],
          ),
          const SizedBox(width: 12),
          _buildAvatar(
            _playerInitial(player),
            AppColors.secondary,
            player: player,
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmedPlayer(BuildContext context, Request r, User? player) {
    final attended = r.attendance == AttendanceStatus.attended;
    final absent = r.attendance == AttendanceStatus.absent;
    final color = attended
        ? AppColors.primary
        : absent
        ? AppColors.tertiary
        : AppColors.secondary;
    final attendanceLabel = attended
        ? 'حاضر'
        : absent
        ? 'غائب'
        : 'لم يُسجّل الحضور';
    final existingRating = _ratings[r.id];
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _buildActionButton(
            icon: attended
                ? Icons.person
                : absent
                ? Icons.person_off_outlined
                : Icons.how_to_reg_outlined,
            color: color,
            backgroundColor: color.withAlpha(25),
            onTap: () => _chooseAttendance(r),
          ),
          if (_game?.status == GameStatus.finished) ...[
            const SizedBox(width: 10),
            _buildActionButton(
              icon: existingRating == null
                  ? Icons.star_outline
                  : Icons.star_rounded,
              color: AppColors.warning,
              backgroundColor: AppColors.warning.withAlpha(25),
              onTap: () => _rate(r, player),
            ),
          ],
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _playerName(player),
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(fontSize: 15),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    existingRating == null
                        ? attendanceLabel
                        : '$attendanceLabel · ${existingRating.rating}/5 ⭐',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text('انضم بنجاح', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const SizedBox(width: 12),
          _buildAvatar(_playerInitial(player), color, player: player),
        ],
      ),
    );
  }

  String _playerName(User? player) =>
      player?.fullname.isNotEmpty == true ? player!.fullname : 'لاعب غير معروف';

  String _playerInitial(User? player) {
    final name = _playerName(player).trim();
    return name.isEmpty ? 'ل' : name.characters.first;
  }

  void _openPlayerProfile(User player) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PlayerProfileScreen(player: player)),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }

  Widget _buildAvatar(String letter, Color color, {User? player}) {
    final avatar = Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        shape: BoxShape.circle,
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
    if (player == null) return avatar;
    return Semantics(
      button: true,
      label: 'عرض ملف ${player.fullname}',
      child: GestureDetector(
        onTap: () => _openPlayerProfile(player),
        child: avatar,
      ),
    );
  }
}
