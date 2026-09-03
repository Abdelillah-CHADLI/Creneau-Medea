import 'package:flutter/material.dart';
import '../../main.dart';
import '../../data/models/player_rating.dart';
import '../../data/models/reservation.dart';
import '../../data/models/game.dart';
import '../theme/app_theme.dart';
import 'edit_profile.dart';
import 'match_history.dart';
import 'settings_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _name;
  String? _username;
  String? _position;
  String? _level;
  double _rating = 0;
  int _ratingCount = 0;
  List<Reservation> _organized = [];
  List<Reservation> _joined = [];
  List<PlayerRating> _ratings = [];
  Map<int, Game> _ratingGames = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cachedUser = authService.currentUser;
    if (cachedUser == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    var user = cachedUser;
    try {
      user = await appData.fetchProfile(cachedUser.id);
      final result = await Future.wait([
        appData.myOrganizedGames(),
        appData.myOrganizedGames(archived: true),
        appData.myJoinedGames(),
        appData.myJoinedGames(archived: true),
        appData.ratingsForPlayer(user.id),
      ]);
      final ratings = result[4] as List<PlayerRating>;
      final games = await Future.wait(
        ratings.map((rating) => appData.gameById(rating.gameId)),
      );
      _organized = [
        ...(result[0] as List<Reservation>),
        ...(result[1] as List<Reservation>),
      ];
      _joined = [
        ...(result[2] as List<Reservation>),
        ...(result[3] as List<Reservation>),
      ];
      _ratings = ratings;
      _ratingGames = {
        for (final game in games.whereType<Game>()) game.id: game,
      };
    } catch (_) {}
    if (mounted) {
      setState(() {
        _name = user.fullname;
        _username = user.username;
        _position = user.position;
        _level = user.level;
        _rating = user.rating;
        _ratingCount = user.ratingCount;
        _loading = false;
      });
    }
  }

  Future<void> _signOut() async {
    await authService.signOut();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
    );
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
            Expanded(child: _buildBody(context)),
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
          GestureDetector(
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
            child: const Icon(
              Icons.settings_outlined,
              size: 24,
              color: AppColors.textDark,
            ),
          ),
          const Spacer(),
          Text(
            'Créneau Médea',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          _buildProfileCard(context),
          const SizedBox(height: 14),
          _buildStats(context),
          if (_ratings.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildRatings(context),
          ],
          const SizedBox(height: 20),
          _buildSettingsSection(context),
          const SizedBox(height: 20),
          _buildSignOut(context),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primarySurface,
              border: Border.all(color: AppColors.primary.withAlpha(51)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(20),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.person, size: 50, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            _loading ? '...' : _name!,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text('@$_username', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              if (_position != null)
                Chip(
                  avatar: const Icon(Icons.sports_soccer, size: 16),
                  label: Text(_position!),
                ),
              if (_level != null)
                Chip(
                  avatar: const Icon(Icons.trending_up, size: 16),
                  label: Text(_levelLabel(_level!)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    final attended = _joined
        .where((item) => item.request.attendance?.name == 'attended')
        .length;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ProfileStat(
                value: '${_organized.length}',
                label: 'مباراة نظّمتها',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ProfileStat(
                value: '${_joined.length}',
                label: 'مباراة انضممت إليها',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _ProfileStat(
                value: '$attended/${_joined.length}',
                label: 'سجل الحضور',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ProfileStat(
                value: _rating == 0 ? '—' : _rating.toStringAsFixed(1),
                label: '$_ratingCount تقييم',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatings(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'تقييماتك حسب المباراة',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 10),
      ..._ratings.map(
        (rating) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.warning.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.star_rounded, color: AppColors.warning),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _ratingGames[rating.gameId]?.title ??
                          'مباراة #${rating.gameId}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${rating.createdAt.day}/${rating.createdAt.month}/${rating.createdAt.year}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Text(
                '${rating.rating}/5',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: AppColors.warning),
              ),
            ],
          ),
        ),
      ),
    ],
  );

  String _levelLabel(String value) =>
      const {
        'beginner': 'مبتدئ',
        'intermediate': 'متوسط',
        'advanced': 'متقدم',
      }[value] ??
      value;

  Widget _buildSettingsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الإعدادات والحساب',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        _SettingsTile(
          icon: Icons.edit_outlined,
          title: 'تعديل الملف الشخصي',
          onTap: () {
            Navigator.of(context)
                .push(
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                )
                .then((_) => _load());
          },
        ),
        const SizedBox(height: 4),
        _SettingsTile(
          icon: Icons.history,
          title: 'المباريات السابقة',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MatchHistoryScreen()),
            );
          },
        ),
        const SizedBox(height: 4),
        _SettingsTile(
          icon: Icons.settings,
          title: 'الإعدادات',
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
          },
        ),
      ],
    );
  }

  Widget _buildSignOut(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: _signOut,
        icon: const Icon(Icons.logout, size: 20),
        label: const Text('تسجيل الخروج'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.tertiary,
          side: const BorderSide(color: AppColors.tertiary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;
  const _ProfileStat({required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 6),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      children: [
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: AppColors.primary),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ),
  );
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.chevron_left,
              size: 22,
              color: AppColors.placeholder,
            ),
            const Spacer(),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontSize: 15),
            ),
            const SizedBox(width: 12),
            Icon(icon, size: 20, color: AppColors.textDark),
          ],
        ),
      ),
    );
  }
}
