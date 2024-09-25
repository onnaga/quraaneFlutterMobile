import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:masjed/core/utils/QuraansoarManage.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:masjed/state/user.dart';



class Register extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => RegisterState();
}


class RegisterState extends State<Register> {
  // GlobalKey<ImageWidgetState> image_key = GlobalKey<ImageWidgetState>();
  GlobalKey<FormState> form_key = GlobalKey<FormState>();
  GlobalKey<ChaptersState> chapters_key = GlobalKey<ChaptersState>();
  String? username;
  String? password;
  String? phone;
  int? age;
  bool busy = false;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: IgnorePointer(
            ignoring: busy,
            child: Form(
              key: form_key,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10 , horizontal: 20),
                child: Column(
                  children: [
                    // -- IMAGE with ICON

                    // ImageWidget(key: image_key),

                    const SizedBox(height: 50),

                    // -- Form Fields

                    TextFormField(
                      validator: username_validator,
                      onSaved: (value){username = value;},
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(45.0),
                          ),
                          label: Text('الاسم الثلاثي'), prefixIcon: Icon(Icons.person)),
                    ),

                    const SizedBox(height: 20),

                    TextFormField(
                      validator: password_validator,
                      onSaved: (value){password = value;},
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(45.0),
                          ),
                          label: Text('كلمة المرور'), prefixIcon: Icon(Icons.password)),
                    ),

                    const SizedBox(height: 20),

                    TextFormField(
                      validator: phone_validator,
                      onSaved: (value){phone = value;},
                      textDirection: TextDirection.ltr,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(45.0),
                          ),
                          label: Text('رقم الهاتف'), prefixIcon: Icon(Icons.phone)),
                    ),

                    const SizedBox(height: 20),

                    DropdownButtonFormField(
                        onSaved: (value){age = value;},
                        validator: age_validator,
                        onChanged: (i){},
                        borderRadius: BorderRadius.circular(15),
                        menuMaxHeight: 200,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(45.0),
                            ),
                            label: Text('اختر العمر'), prefixIcon: Icon(Icons.calendar_today)
                        ),
                        items: List.generate(20, (i){
                          return DropdownMenuItem(
                            value: i+1,
                            child: Center(child: Text(((i+1).toString())),),
                          );
                        })
                    ),

                    const SizedBox(height: 20),

                    Chapters(key: chapters_key),

                    const SizedBox(height: 20),

                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('أملك حسابا بالفعل'),
                        TextButton(
                                        child: Center(child: Text('تسجيل الدخول ',style: TextStyle(color: const Color.fromARGB(255, 114, 76, 175),fontWeight: FontWeight.bold),),),
                                      onPressed: (){Navigator.pop(context);},
                                    ),
                      ],
                    ),

            const SizedBox(height: 20),
                    // -- Form Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          User user = Provider.of<User>(context,listen: false);
                          FormState form_state = form_key.currentState as FormState;
                          // ImageWidgetState image_state = image_key.currentState as ImageWidgetState;
                          ChaptersState chapter_state = chapters_key.currentState as ChaptersState;
                          if (!form_state.validate()){return;}
                          form_state.save();
                          setState(() {busy = true;});
                          List<int> chapters = chapter_state.get_chapters();
                          // File image = await image_state.getImage();
                          
                          user.register(context, username as String, password as String, phone as String, age as int, chapters)
                              .then((auth){
                            if (auth) {WidgetsBinding.instance.addPostFrameCallback((d){
                              var nav = Navigator.of(context);
                              nav.pop();
                              nav.popAndPushNamed('redirect');
                            });}
                            else {WidgetsBinding.instance.addPostFrameCallback((d){setState(() {busy = false;});});}
                          });
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            side: BorderSide.none,
                            shape: const StadiumBorder()),
                        child:  (busy) ?  const SizedBox(width: 25,height: 25,child: CircularProgressIndicator(color: Colors.white,strokeWidth: 2,)) :  const Text('انشاء الحساب', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  
  
                  ],
                ),
              ),
            ),
          )
        ),
      )
    );
  }


  String? username_validator (String? value) {
    if (value == ''){return 'ادخل اسم المستخدم';}
    return null;
  }

  String? password_validator (String? value) {
    if (value == ''){return 'ادخل كلمة مرور';}
    return null;
  }

  static RegExp phone_validator_regex = RegExp(r'^(\+963|0)[0-9]{9}$');
  String? phone_validator (String? value) {
    value = value as String;
    if (value == ''){return 'ادخل رقم الهاتف';}
    else if (!value.contains(phone_validator_regex)) {return 'رقم هاتف غير صالح';}
    return null;
  }

  String? age_validator (int? value) {
    if (value == null){return 'ادخل العمر';}
    return null;
  }

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



class Chapters extends StatefulWidget {
  Chapters({required super.key});

  @override
  State<StatefulWidget> createState() => ChaptersState();
}

class ChaptersState extends State<Chapters> {
  final List<Map<String,dynamic>> list = List.generate(30, (i){return {'name': juz_list[i] , 'checked': false };});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 50,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(45),border: Border.all(width: 1,color: const Color.fromARGB(255, 0, 0, 0))),
      child: TextButton(
        onPressed: (){
          showDialog(
              context: context,
              barrierDismissible: true,
              builder: (context) {
                return SimpleDialog(
                  children: List.generate(30, (i){
                    return ListTile(
                        title: Text(list[i]['name']),
                        leading: ChapterButton(i,list)
                    );
                  }),
                );
              }
          );
        },
        child: Text('تحديد الأجزاء المحفوظة',style: TextStyle(color: Color.fromARGB(255, 58, 106, 57),fontWeight: FontWeight.bold),),
      ),
    );
  }

  List<int> get_chapters () {
    List<int> chapters = [];
    for (int i = 0 ; i<30 ; i++) { if (list[i]['checked']) {chapters.add(i+1);} }
    return chapters;
  }

  static final List<String> juz_list = Quraansoarmanage.AzaaList;}



class ChapterButton extends StatefulWidget {
  final int i;
  final List<Map<String,dynamic>> list;
  ChapterButton(this.i,this.list);

  @override
  State<StatefulWidget> createState() => ChapterButtonState();
}

class ChapterButtonState extends State<ChapterButton> {
  @override
  Widget build(BuildContext context) {
    return Checkbox(
      activeColor: Colors.green,
      value: widget.list[widget.i]['checked'],
      onChanged: (v){setState(() {
        widget.list[widget.i]['checked'] = v;
      });},
    );
  }
}
