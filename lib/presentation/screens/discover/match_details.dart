import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/models/game.dart';
import '../../../data/models/request.dart';
import '../../../data/models/pitch.dart';
import '../../../data/models/user.dart';
import '../../../main.dart';
import '../../theme/app_theme.dart';
import '../my_matches/player_profile.dart';

class MatchDetailsScreen extends StatefulWidget {
  final int gameId;

  const MatchDetailsScreen({super.key, required this.gameId});

  @override
  State<MatchDetailsScreen> createState() => _MatchDetailsScreenState();
}

class _MatchDetailsScreenState extends State<MatchDetailsScreen> {
  Game? _game;
  bool _loading = true;
  bool _error = false;
  bool _joining = false;
  int _acceptedCount = 0;
  Request? _myRequest;
  Pitch? _pitch;
  User? _organizer;
  List<String> _needs = [];

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
      final game = await appData.gameById(widget.gameId);
      final results = await Future.wait([
        appData.acceptedRequestCount(widget.gameId),
        appData.myRequestForGame(widget.gameId),
        appData.pitches(),
        appData.gameNeedNamesForGames([widget.gameId]),
      ]);
      User? organizer;
      if (game != null) {
        try {
          organizer = await appData.fetchProfile(game.userId);
        } catch (_) {}
      }
      if (mounted) {
        setState(() {
          _game = game;
          _acceptedCount = results[0] as int;
          _myRequest = results[1] as Request?;
          final pitches = results[2] as List<Pitch>;
          _pitch = pitches
              .where((pitch) => pitch.id == game?.pitchId)
              .firstOrNull;
          _needs = ((results[3] as Map<int, Set<String>>)[widget.gameId] ?? {})
              .toList();
          _organizer = organizer;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _error = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _join() async {
    setState(() => _joining = true);
    try {
      await appData.sendJoinRequest(widget.gameId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال طلب الانضمام بنجاح')),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل إرسال الطلب: $e')));
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            border: Border.symmetric(
              vertical: BorderSide(color: AppColors.accent, width: 2),
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(child: _buildBody(context)),
                if (_game != null) _buildBottomBar(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: AppColors.textDark,
            ),
          ),
          const Spacer(),
          Text(
            'تفاصيل المباراة',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const Spacer(),
          GestureDetector(
            onTap: _share,
            child: const Icon(
              Icons.share_outlined,
              size: 20,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error || _game == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('تعذر تحميل المباراة'),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _load,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }
    final game = _game!;
    return SingleChildScrollView(
      child: Column(
        children: [
          _PitchHero(pitch: _pitch),
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  game.title ?? 'مباراة',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                _InfoRow(
                  icon: Icons.flag_outlined,
                  label: 'الحالة',
                  value: _statusLabel(game.status),
                  iconColor: AppColors.primary,
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.stadium_outlined,
                  label: 'الملعب',
                  value: _pitch?.name ?? 'تعذر تحديد الملعب',
                  iconColor: AppColors.secondary,
                ),
                if (_pitch?.location?.isNotEmpty == true) ...[
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'الموقع',
                    value: _pitch!.location!,
                    iconColor: AppColors.secondary,
                  ),
                ],
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.people_outline,
                  label: 'اللاعبون',
                  value: '$_acceptedCount / ${game.maxPlayers} لاعب مؤكد',
                  iconColor: AppColors.primary,
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'التاريخ',
                  value: _formatDate(game.startingTime),
                  iconColor: AppColors.primary,
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.access_time,
                  label: 'الوقت',
                  value:
                      '${_formatTime(game.startingTime)} - ${_formatTime(game.endingTime)}',
                  iconColor: AppColors.primary,
                ),
                if (game.price != null) ...[
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.payments_outlined,
                    label: 'السعر',
                    value: '${game.price} دج',
                    iconColor: AppColors.secondary,
                  ),
                ],
                if (game.body != null) ...[
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.notes,
                    label: 'ملاحظات',
                    value: game.body!,
                    iconColor: AppColors.textMuted,
                  ),
                ],
              ],
            ),
          ),
          if (_needs.isNotEmpty) _buildNeeds(context),
          _buildOrganizer(context),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildNeeds(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ما الذي تحتاجه المباراة؟',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _needs
              .map(
                (need) => Chip(
                  avatar: const Icon(
                    Icons.check_circle_outline,
                    size: 17,
                    color: AppColors.primary,
                  ),
                  label: Text(_needLabel(need)),
                  backgroundColor: AppColors.primarySurface,
                  side: BorderSide.none,
                ),
              )
              .toList(),
        ),
      ],
    ),
  );

  Widget _buildOrganizer(BuildContext context) {
    final organizer = _organizer;
    return Semantics(
      button: organizer != null,
      label: 'عرض ملف منظم المباراة',
      child: InkWell(
        onTap: organizer == null
            ? null
            : () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlayerProfileScreen(player: organizer),
                ),
              ),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primarySurface,
                child: Text(
                  (organizer?.fullname.trim().isNotEmpty == true
                      ? organizer!.fullname.trim().characters.first
                      : 'م'),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'منظم المباراة',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      organizer?.fullname ?? 'بيانات المنظم غير متاحة',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (organizer != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: AppColors.warning,
                            size: 17,
                          ),
                          Text(
                            organizer.rating == 0
                                ? ' منظم جديد'
                                : ' ${organizer.rating.toStringAsFixed(1)} (${organizer.ratingCount})',
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              if (organizer != null) const Icon(Icons.chevron_left),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _share() async {
    final game = _game;
    if (game == null) return;
    await Clipboard.setData(
      ClipboardData(
        text:
            '${game.title ?? 'مباراة'}\n${_formatDate(game.startingTime)} · ${_formatTime(game.startingTime)}',
      ),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم نسخ تفاصيل المباراة للمشاركة')),
      );
    }
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
        color: AppColors.background,
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _joinEnabled ? _join : null,
            icon: _joining
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.directions_run, size: 22),
            label: Text(
              _joinLabel,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }

  bool get _joinEnabled {
    final game = _game;
    if (game == null || _joining || _myRequest != null) return false;
    if (authService.currentUser?.id == game.userId) return false;
    return game.status == GameStatus.pending &&
        _acceptedCount < game.maxPlayers;
  }

  String get _joinLabel {
    if (_game != null && authService.currentUser?.id == _game!.userId) {
      return 'أنت منظم هذه المباراة';
    }
    if (_myRequest?.status == RequestStatus.pending) return 'طلبك قيد المراجعة';
    if (_myRequest?.status == RequestStatus.accepted) return 'تم قبول انضمامك';
    if (_game != null && _acceptedCount >= _game!.maxPlayers) {
      return 'اكتمل العدد';
    }
    return 'انضم للمباراة';
  }

  String _needLabel(String value) =>
      const {
        'players': 'لاعبون',
        'opponent': 'خصم',
        'football': 'كرة',
        'pump': 'مضخة',
        'lighting': 'إضاءة',
        'pitch_available': 'ملعب متاح',
      }[value] ??
      value;

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

  String _formatDate(DateTime d) {
    const weekdays = {
      DateTime.monday: 'الإثنين',
      DateTime.tuesday: 'الثلاثاء',
      DateTime.wednesday: 'الأربعاء',
      DateTime.thursday: 'الخميس',
      DateTime.friday: 'الجمعة',
      DateTime.saturday: 'السبت',
      DateTime.sunday: 'الأحد',
    };
    return '${weekdays[d.weekday]}, ${d.day}/${d.month}/${d.year}';
  }

  String _formatTime(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _PitchHero extends StatelessWidget {
  final Pitch? pitch;
  const _PitchHero({this.pitch});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    height: 190,
    width: double.infinity,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF0C7A45), Color(0xFF075E36)],
      ),
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withAlpha(45),
          blurRadius: 22,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Stack(
      children: [
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: CustomPaint(painter: _PitchPainter()),
          ),
        ),
        const Center(
          child: Icon(Icons.sports_soccer, color: Colors.white, size: 40),
        ),
        Positioned(
          right: 22,
          left: 22,
          bottom: 18,
          child: Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  pitch?.name ?? 'ملعب المباراة',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _PitchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(105)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      paint,
    );
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 28, paint);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * .27, 42, size.height * .46),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width - 42, size.height * .27, 42, size.height * .46),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withAlpha(25),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.placeholder,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
