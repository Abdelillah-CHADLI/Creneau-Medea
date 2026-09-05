import 'package:flutter/material.dart';
import '../../main.dart';
import '../theme/app_theme.dart';
import '../widgets/app_components.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _position;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = authService.currentUser;
    _nameController.text = user?.fullname ?? '';
    _phoneController.text = user?.phoneNumber ?? '';
    _position = user?.position;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final fullname = _nameController.text.trim();
    if (fullname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال الاسم الكامل')),
      );
      return;
    }
    if (_position == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('اختر مركز لعبك قبل الحفظ')));
      return;
    }
    setState(() => _saving = true);
    try {
      await authService.updateProfile(
        fullname: fullname,
        phoneNumber: _phoneController.text.trim(),
        position: _position,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم حفظ التعديلات')));
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل الحفظ: $e')));
      setState(() => _saving = false);
    }
  }

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
              _buildSaveBar(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return AppTopBar(
      title: 'تعديل الملف الشخصي',
      subtitle: 'اجعل بياناتك واضحة للمنظّمين',
      showLogo: false,
      leading: IconButton(
        tooltip: 'رجوع',
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_forward_ios, size: 20),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: AppConstrainedContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الاسم الكامل',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: _decoration(Icons.person_outline, 'محمد شادي'),
            ),
            const SizedBox(height: 16),
            Text('رقم الهاتف', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: _decoration(Icons.phone, '0555 12 34 56'),
            ),
            const SizedBox(height: 16),
            Text('المركز', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _position,
              decoration: _decoration(
                Icons.sports_soccer,
                'اختر مركزك الأساسي',
              ),
              items: const [
                DropdownMenuItem(value: 'هجوم', child: Text('هجوم')),
                DropdownMenuItem(value: 'وسط', child: Text('وسط')),
                DropdownMenuItem(value: 'دفاع', child: Text('دفاع')),
                DropdownMenuItem(value: 'حارس مرمى', child: Text('حارس مرمى')),
              ],
              onChanged: (v) => setState(() => _position = v),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _decoration(IconData icon, String hint) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.primary),
      filled: true,
      fillColor: AppColors.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
    );
  }

  Widget _buildSaveBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
        color: AppColors.background,
      ),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 52),
          child: ElevatedButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check, size: 20),
            label: const Text('حفظ التعديلات'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }
}
