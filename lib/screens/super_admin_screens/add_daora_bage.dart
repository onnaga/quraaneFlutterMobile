import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:masjed/core/utils/snackBarHelper.dart';
import 'package:masjed/core/widgets/modern_loader.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';
import 'package:masjed/state/daoraState.dart';

class AddDaoraPage extends StatefulWidget {
  const AddDaoraPage({super.key});

  @override
  State<AddDaoraPage> createState() => _AddDaoraPageState();
}

class _AddDaoraPageState extends State<AddDaoraPage> {
  final _formKey = GlobalKey<FormState>();

  String? daoraName;
  String? adminName;
  String? password;
  File? photo;

  bool busy = false;

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        photo = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var daoraState = Provider.of<Daorastate>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("إضافة دورة جديدة"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: "اسم الدورة"),
                validator: (val) =>
                    val == null || val.isEmpty ? "أدخل اسم الدورة" : null,
                onSaved: (val) => daoraName = val,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: "اسم المشرف"),
                validator: (val) =>
                    val == null || val.isEmpty ? "أدخل اسم المشرف" : null,
                onSaved: (val) => adminName = val,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: "كلمة المرور"),
                obscureText: true,
                validator: (val) =>
                    val == null || val.isEmpty ? "أدخل كلمة المرور" : null,
                onSaved: (val) => password = val,
              ),
              const SizedBox(height: 12),
              photo == null
                  ? TextButton.icon(
                      onPressed: pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text("إضافة صورة للدورة"),
                    )
                  : Column(
                      children: [
                        Image.file(photo!, height: 120),
                        TextButton(
                          onPressed: pickImage,
                          child: const Text("تغيير الصورة"),
                        )
                      ],
                    ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: busy
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) return;
                        _formKey.currentState!.save();

                        setState(() => busy = true);
                        final user = Provider.of<User>(context, listen: false);
                        String msg = await daoraState.addDaora(
                          daoraName!,
                          adminName!,
                          password!,
                          photo,
                          user.token!,
                          
                        );

                        setState(() => busy = false);
                        showStyledSnackBar(context,
                        
                            message: msg, isError: false);

                        if (msg.contains("تم إنشاء")) {
                          Navigator.pop(
                              context, true); // نرجع true للإشارة للنجاح
                        }
                      },
                child: busy
                    ? const ModernLoader(color: Colors.white)
                    : const Text("إنشاء الدورة"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
