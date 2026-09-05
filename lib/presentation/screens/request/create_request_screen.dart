import 'package:flutter/material.dart';
import '../../../data/models/pitch.dart';
import '../../../main.dart';
import 'create_request_data.dart';
import 'request_info.dart';
import 'request_details.dart';
import 'request_needs.dart';
import 'confirm_request.dart';

class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final _data = CreateRequestData();
  int _currentStep = 0;

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _publish() async {
    final data = _data;
    if (data.type == null ||
        data.title?.trim().isEmpty != false ||
        data.date == null ||
        data.startTime == null ||
        data.endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أكمل تفاصيل الطلب قبل النشر')),
      );
      return;
    }
    try {
      final pitches = await appData.pitches();
      if (pitches.isEmpty) {
        throw Exception('لا توجد ملاعب متاحة');
      }
      Pitch pitch;
      if (data.pitchName != null) {
        pitch = pitches.firstWhere(
          (p) => p.name == data.pitchName,
          orElse: () => pitches.first,
        );
      } else {
        pitch = pitches.first;
      }

      final startingTime = DateTime(
        data.date!.year,
        data.date!.month,
        data.date!.day,
        data.startTime!.hour,
        data.startTime!.minute,
      );
      final endingTime = DateTime(
        data.date!.year,
        data.date!.month,
        data.date!.day,
        data.endTime!.hour,
        data.endTime!.minute,
      );

      if (!endingTime.isAfter(startingTime)) {
        throw Exception('يجب أن يكون وقت النهاية بعد وقت البداية');
      }

      final game = await appData.createGame(
        startingTime: startingTime,
        endingTime: endingTime,
        pitchId: pitch.id,
        title: data.title!.trim(),
        body: data.notes,
        price: data.price,
        maxPlayers: data.playerCount ?? 10,
        needNames: [
          if (data.type == RequestType.needPlayers) 'players',
          if (data.type == RequestType.lookingForOpponent) 'opponent',
          if (data.type == RequestType.pitchAvailable) 'pitch_available',
          ...data.equipment,
        ],
      );

      if (await storageService.areNotificationsEnabled()) {
        final reminder = startingTime.subtract(const Duration(hours: 1));
        if (reminder.isAfter(DateTime.now())) {
          await notificationService.scheduleNotification(
            id: game.id,
            title: 'تذكير بالمباراة',
            body: '${game.title ?? 'مباراة'} تبدأ خلال ساعة',
            scheduledTime: reminder,
          );
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم إنشاء الطلب بنجاح')));
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل إنشاء الطلب: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: IndexedStack(
            index: _currentStep,
            children: [
              RequestInfoStep(
                data: _data,
                onNext: _nextStep,
                onBack: _prevStep,
              ),
              RequestDetailsStep(
                data: _data,
                onNext: _nextStep,
                onBack: _prevStep,
              ),
              RequestNeedsStep(
                data: _data,
                onNext: _nextStep,
                onBack: _prevStep,
              ),
              ConfirmRequestStep(
                data: _data,
                onPublish: _publish,
                onBack: _prevStep,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
