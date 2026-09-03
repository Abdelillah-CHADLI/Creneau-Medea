import 'package:flutter/material.dart';
import '../../../data/models/reservation.dart';
import '../../../main.dart';
import '../../theme/app_theme.dart';

class ArchivedMatchesScreen extends StatefulWidget {
  const ArchivedMatchesScreen({super.key});

  @override
  State<ArchivedMatchesScreen> createState() => _ArchivedMatchesScreenState();
}

class _ArchivedMatchesScreenState extends State<ArchivedMatchesScreen> {
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
        appData.myOrganizedGames(archived: true),
        appData.myJoinedGames(archived: true),
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

  Future<void> _restore(Reservation item, bool organized) async {
    try {
      if (organized) {
        await appData.setOrganizedGameArchived(item.game.id, false);
      } else {
        await appData.setJoinedGameArchived(item.request.id, false);
      }
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تمت إعادة المباراة إلى مبارياتي')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذر استرجاع المباراة: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      appBar: AppBar(title: const Text('المباريات المؤرشفة')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error
          ? Center(
              child: OutlinedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
              ),
            )
          : _organized.isEmpty && _joined.isEmpty
          ? const Center(child: Text('لا توجد مباريات مؤرشفة'))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (_organized.isNotEmpty) ...[
                    Text(
                      'مباريات نظّمتها',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    ..._organized.map(
                      (item) => _ArchivedTile(
                        item: item,
                        onRestore: () => _restore(item, true),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (_joined.isNotEmpty) ...[
                    Text(
                      'مباريات انضممت إليها',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    ..._joined.map(
                      (item) => _ArchivedTile(
                        item: item,
                        onRestore: () => _restore(item, false),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    ),
  );
}

class _ArchivedTile extends StatelessWidget {
  final Reservation item;
  final VoidCallback onRestore;
  const _ArchivedTile({required this.item, required this.onRestore});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Material(
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: AppColors.primarySurface,
          child: Icon(Icons.inventory_2_outlined, color: AppColors.primary),
        ),
        title: Text(item.game.title ?? 'مباراة'),
        subtitle: Text(
          '${item.game.startingTime.day}/${item.game.startingTime.month}/${item.game.startingTime.year} · ${item.pitch?.name ?? 'الملعب'}',
        ),
        trailing: IconButton(
          tooltip: 'استرجاع',
          onPressed: onRestore,
          icon: const Icon(Icons.unarchive_outlined, color: AppColors.primary),
        ),
      ),
    ),
  );
}
