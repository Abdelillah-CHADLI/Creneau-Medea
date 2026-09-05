import 'package:flutter/material.dart';

import '../../main.dart';
import '../theme/app_theme.dart';
import '../screens/notifications/notification.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final enabled = await storageService.areNotificationsEnabled();
    if (mounted) setState(() => _notifications = enabled);
  }

  Future<void> _setNotifications(bool value) async {
    if (value) {
      final allowed = await notificationService.requestPermission();
      if (!allowed) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('يرجى السماح بالإشعارات من إعدادات الجهاز'),
            ),
          );
        }
        return;
      }
    }
    await storageService.setNotificationsEnabled(value);
    if (mounted) setState(() => _notifications = value);
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.inbox_outlined,
                color: AppColors.primary,
              ),
              title: const Text('صندوق الإشعارات'),
              subtitle: const Text('طلبات الانضمام وتحديثات المباريات'),
              trailing: const Icon(Icons.chevron_left),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('التنبيهات', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: SwitchListTile.adaptive(
              value: _notifications,
              activeTrackColor: AppColors.primary,
              onChanged: _setNotifications,
              title: const Text('تنبيهات المباريات'),
              subtitle: const Text('تذكيرك بالمباريات والطلبات الجديدة'),
              secondary: const Icon(
                Icons.notifications_outlined,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('عن التطبيق', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const Card(
            child: ListTile(
              leading: Icon(Icons.info_outline, color: AppColors.primary),
              title: Text('Créneau Médéa'),
              subtitle: Text('الإصدار 1.0.0'),
            ),
          ),
        ],
      ),
    ),
  );
}
