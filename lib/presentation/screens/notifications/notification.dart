import 'package:flutter/material.dart';

import '../../../data/models/app_notification.dart';
import '../../../main.dart';
import '../../theme/app_theme.dart';
import '../discover/match_details.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _loading = true;
  List<AppNotification> _items = [];
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await appData.notifications();
      if (mounted) setState(() => _items = items);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تعذر تحميل الإشعارات')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _open(AppNotification item) async {
    await appData.markNotificationRead(item.id);
    if (!mounted || item.gameId == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MatchDetailsScreen(gameId: item.gameId!),
      ),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      appBar: AppBar(title: const Text('الإشعارات')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 56,
                    color: AppColors.placeholder,
                  ),
                  SizedBox(height: 12),
                  Text('لا توجد إشعارات جديدة'),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (_, index) {
                  final item = _items[index];
                  return ListTile(
                    tileColor: item.readAt == null
                        ? AppColors.primarySurface
                        : null,
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primarySurface,
                      child: Icon(
                        Icons.notifications_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    title: Text(item.title),
                    subtitle: Text(item.body),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () => _open(item),
                  );
                },
              ),
            ),
    ),
  );
}
