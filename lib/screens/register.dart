import 'package:flutter/material.dart';
import 'package:masjed/core/utils/snackBarHelper.dart';
import 'package:masjed/core/widgets/AutoCompleteAgeAreaLogic.dart';
import 'package:masjed/core/widgets/RealisticAtomLoader.dart';
import 'package:masjed/core/widgets/chapters.dart';
import 'package:masjed/core/widgets/modern_loader.dart';
import 'package:masjed/screens/DaoraSelectionPage.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<StatefulWidget> createState() => RegisterState();
}

class RegisterState extends State<Register> {
  GlobalKey<FormState> form_key = GlobalKey<FormState>();
  GlobalKey<ChaptersState> chapters_key = GlobalKey<ChaptersState>();
  String? username;
  String? password;
  String? phone;
  int? age;
  bool busy = false;
  int? selectedDaoraId;
  String? selectedDaoraName;
  String? job;
  String? address;
  String? familyStatus;

  // ✅ إضافة controllers لحقول الإكمال التلقائي
  final TextEditingController _jobController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  late Future<Map<String, List<String>>> _suggestionsFuture;

  @override
  void initState() {
    super.initState();
    // ✅ استدعاء الدالة لجلب البيانات عند بدء الشاشة
    final authProvider = Provider.of<User>(context, listen: false);
    _suggestionsFuture = authProvider.fetchSuggestions();
  }

  @override
  void dispose() {
    _jobController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[100],
        body: FutureBuilder<Map<String, List<String>>>(
            future: _suggestionsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: RealisticAtomLoader());
              }

              if (snapshot.hasError) {
                // print('data is  : ${snapshot.data}');
                // print('////////////////////////////////////////////////////////////////////////////////////');
//  print('error is  : ${snapshot.error}');
                return const Center(child: Text('حدث خطأ في تحميل البيانات'));

              }else{
              // ✅ البيانات جاهزة

              }

              final suggestions = snapshot.data ?? {'jobs': [], 'areas': []};
              final jobSuggestions = suggestions['jobs']!;
              final areaSuggestions = suggestions['areas']!;

              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: IgnorePointer(
                    ignoring: busy,
                    child: Form(
                      key: form_key,
                      child: Column(
                        children: [
                          const SizedBox(height: 30),
                          // العنوان
                          Text(
                            "إنشاء حساب جديد",
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey[800],
                                ),
                          ),
                          const SizedBox(height: 30),
                          // اختيار الدورة
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 20),
                              shape: const StadiumBorder(),
                            ),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const DaoraSelectionPage(),
                                ),
                              );

                              if (result != null && result is Map) {
                                setState(() {
                                  selectedDaoraId = result["id"];
                                  selectedDaoraName = result["name"];
                                });
                              }
                            },
                            icon: const Icon(Icons.mosque, color: Colors.white),
                            label: Text(
                              selectedDaoraName ?? "اختر الدورة",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // الاسم
                          TextFormField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(45)),
                              label: const Text("الاسم الثلاثي"),
                              prefixIcon: const Icon(Icons.person),
                            ),
                            validator: username_validator,
                            onSaved: (val) => username = val,
                          ),
                          const SizedBox(height: 20),

                          // كلمة المرور
                          TextFormField(
                            obscureText: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(45)),
                              label: const Text("كلمة المرور"),
                              prefixIcon: const Icon(Icons.lock),
                            ),
                            validator: password_validator,
                            onSaved: (val) => password = val,
                          ),
                          const SizedBox(height: 20),

                          // الهاتف
                          TextFormField(
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(45)),
                              label: const Text("رقم الهاتف"),
                              prefixIcon: const Icon(Icons.phone),
                            ),
                            validator: phone_validator,
                            onSaved: (val) => phone = val,
                          ),
                          const SizedBox(height: 20),

                          // العمر
                          DropdownButtonFormField<int>(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(45)),
                              label: const Text("اختر العمر"),
                              prefixIcon: const Icon(Icons.calendar_today),
                            ),
                            items: List.generate(70, (i) {
                              return DropdownMenuItem(
                                value: i + 1,
                                child: Center(child: Text("${i + 1}")),
                              );
                            }),
                            onChanged: (value) {
                              setState(() => age = value);
                            },
                            validator: age_validator,
                            onSaved: (val) => age = val,
                          ),
                          const SizedBox(height: 20),
    // ✅ استبدال TextFormField القديم بالـ Widget الجديد للعمل
                AutocompleteTextField(
                  controller: _jobController,
                  label: "عمل ولي الأمر",
                  icon: Icons.work,
                  suggestions: jobSuggestions,
                  validator: (val) => val == null || val.isEmpty ? "ادخل العمل" : null,
                  onSaved: (val) => job = val,
                ),
                
                const SizedBox(height: 20),

                // ✅ استبدال TextFormField القديم بالـ Widget الجديد لمكان السكن
                AutocompleteTextField(
                  controller: _addressController,
                  label: "مكان السكن",
                  icon: Icons.home,
                  suggestions: areaSuggestions,
                  validator: (val) => val == null || val.isEmpty ? "ادخل مكان السكن" : null,
                  onSaved: (val) => address = val,
                ),

                const SizedBox(height: 20),// الوضع الأسري (اختياري)
                          TextFormField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(45)),
                              label: const Text("الوضع الأسري (اختياري)"),
                              prefixIcon: const Icon(Icons.family_restroom),
                            ),
                            onSaved: (val) => familyStatus = val,
                          ),
                          const SizedBox(height: 20),
                          Chapters(
                            key: chapters_key,
                            initialSelected: const [],
                          ),

                          const SizedBox(height: 20),


                          // زر التسجيل
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                shape: const StadiumBorder(),
                              ),
                              onPressed: () async {
                                final user =
                                    Provider.of<User>(context, listen: false);
                                final formState =
                                    form_key.currentState as FormState;
                                final chapterState =
                                    chapters_key.currentState as ChaptersState;

                                if (!formState.validate()) return;
                                if (selectedDaoraId == null) {
                                  showStyledSnackBar(context,
                                      message: "الرجاء اختيار دورة",
                                      isError: true);
                                  return;
                                }

                                formState.save();
                                setState(() {
                                  busy = true;
                                });

                                final List<int> chapters =
                                    chapterState.get_chapters();

                                try {
                                  final bool auth = await user.register(
                                    username as String,
                                    password as String,
                                    phone as String,
                                    age as int,
                                    chapters,
                                    selectedDaoraId!,
                                    job as String,
                                    address as String,
                                    familyStatus,
                                  );
                                  if (!context.mounted) return;

                                  if (auth) {
                                    Navigator.of(context)
                                        .popAndPushNamed('redirect');
                                  }
                                } catch (e) {
                                  if (!context.mounted) return;
                                  showStyledSnackBar(context,
                                      message: e.toString(), isError: true);
                                } finally {
                                  // هذا الكود سيعمل دائماً، سواء نجحت العملية أو فشلت
                                  setState(() {
                                    busy = false;
                                  });
                                }
                              },
                              child: busy
                                  ? const ModernLoader(size: 25)
                                  : const Text(
                                      "إنشاء الحساب",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // تسجيل الدخول
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('أملك حسابا بالفعل'),
                              TextButton(
                                child: const Center(
                                  child: Text(
                                    'تسجيل الدخول ',
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 114, 76, 175),
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }));
  }

  String? username_validator(String? value) {
    if (value == '') {
      return 'ادخل اسم المستخدم';
    }
    return null;
  }

  String? password_validator(String? value) {
    if (value == '') {
      return 'ادخل كلمة مرور';
    }
    return null;
  }

  static RegExp phone_validator_regex = RegExp(r'^(09\d{8}|05\d{9})$');
  String? phone_validator(String? value) {
    value = value as String;
    if (value == '') {
      return 'ادخل رقم الهاتف';
    } else if (!value.contains(phone_validator_regex)) {
      return 'الرقم يجب أن يكون سوري (09 + 8 أرقام) أو تركي (05 + 9 أرقام)';
    }
    return null;
  }

  String? age_validator(int? value) {
    if (value == null) {
      return 'ادخل العمر';
    }
    return null;
  }
}

String? username_validator(String? value) {
  if (value == '') {
    return 'ادخل اسم المستخدم';
  }
  return null;
}

String? password_validator(String? value) {
  if (value == '') {
    return 'ادخل كلمة مرور';
  }
  return null;
}

RegExp phone_validator_regex = RegExp(r'^(\+963|0)[0-9]{9}$');
String? phone_validator(String? value) {
  value = value as String;
  if (value == '') {
    return 'ادخل رقم الهاتف';
  } else if (!value.contains(phone_validator_regex)) {
    return 'رقم هاتف غير صالح';
  }
  return null;
}

String? age_validator(int? value) {
  if (value == null) {
    return 'ادخل العمر';
  }
  return null;
}


// class ImageWidget extends StatefulWidget {
//   ImageWidget({required super.key});

//   final picker = ImagePicker();

//   @override
//   State<StatefulWidget> createState() => ImageWidgetState();
// }

// class ImageWidgetState extends State<ImageWidget> {
//   File? image;

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         TextButton(
//             onPressed: (){
//               showDialog(
//                   context: context,
//                   barrierDismissible: true,
//                   builder: (context) {
//                     return SimpleDialog(
//                       contentPadding: EdgeInsets.zero,
//                       children: [SizedBox(height: 400,child: (image == null) ? Image.asset('images/avatar.png',fit: BoxFit.fill) : Image.file(image as File,fit: BoxFit.fill),)]
//                     );
//                   }
//               );
//             },
//             child: SizedBox(
//               width: 160,
//               height: 160,
//               child: ClipRRect(
//                   borderRadius: BorderRadius.circular(100),
//                   child: (image == null) ? Image.asset('images/avatar.png',fit: BoxFit.fill) : Image.file(image as File,fit: BoxFit.fill)
//               ),
//             ),),
//         Positioned(
//           bottom: 0,
//           right: 0,
//           child: Container(
//             width: 35,
//             height: 35,
//             decoration:
//             BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.green),
//             child: IconButton(
//               icon: Icon(Icons.edit,color: Colors.white,size: 20,),
//               onPressed: () async {
//                 widget.picker.pickImage(
//                   source: ImageSource.gallery,
//                   imageQuality: 100,
//                 )
//                     .then((file){
//                   if (file == null) {return;}
//                   setState(() {
//                     image = File(file.path);
//                   });
//                 });
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Future<File> getImage () async {
//     if (image == null) {return getImageFileFromAssets();}
//     else {return image as File;}
//   }

//   Future<File> getImageFileFromAssets() async {
//     final byteData = await rootBundle.load('images/avatar.png');
//     final file = File('${(await getTemporaryDirectory()).path}/images/avatar.png');
//     await file.create(recursive: true);
//     await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
//     return file;
//   }

// }

