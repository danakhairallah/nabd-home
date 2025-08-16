import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = 'محمد';
  String phoneNumber = '+962788048682';

  Future<void> _editField(
      String title, String currentValue, Function(String) onSave) async {
    final controller = TextEditingController(text: currentValue);

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
              Theme.of(context).colorScheme.surface.withOpacity(0.9),
          title: Text('تعديل $title',
              style: Theme.of(context).textTheme.titleLarge),
          content: TextField(
            controller: controller,
            textDirection: TextDirection.rtl,
            style: Theme.of(context).textTheme.bodyLarge,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'أدخل $title الجديد',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );

    if (result != null && result.trim().isNotEmpty) {
      setState(() => onSave(result.trim()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Text(
                    'معلومات الحساب',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(flex: 2),
                ],
              ),
              const SizedBox(height: 120),

              _buildInfoField(
                label: 'الاسم',
                value: userName,
                onEdit: () =>
                    _editField('الاسم', userName, (val) => userName = val),
              ),
              const SizedBox(height: 30),

              _buildInfoField(
                label: 'رقم الهاتف',
                value: phoneNumber,
                onEdit: () => _editField(
                    'رقم الهاتف', phoneNumber, (val) => phoneNumber = val),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoField({
    required String label,
    required String value,
    required VoidCallback onEdit,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 15, color: Colors.white),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: const TextStyle(fontSize: 17, color: Colors.white),
              ),
              const Divider(color: Colors.white),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.white),
          onPressed: onEdit,
        ),
      ],
    );
  }
}
