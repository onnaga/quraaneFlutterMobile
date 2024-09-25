import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:masjed/core/utils/sizeConfig.dart';
import 'package:masjed/data/objects.dart';
import 'package:masjed/screens/admin_screens/testsScreens/OnActions%20Screens/showSuccesUserInTest.dart';
import 'package:masjed/screens/admin_screens/testsScreens/OnActions%20Screens/showTestAccepters.dart';
import 'package:masjed/screens/admin_screens/testsScreens/ShowTests.dart';
import 'package:masjed/state/profile.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';

class TestCard extends StatelessWidget {
  TestData data;
  final Function(Profile profile) methodFromParent;

  TestCard({required this.data ,required this.methodFromParent});


  @override
  Widget build(BuildContext context) {
    
    return Consumer<Profile>(builder: (context, profile, child) {
  User user  = Provider.of<User>(context,listen: false);
  int userPrivilige = user.privilege!;
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        decoration:        const BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(35),
              topRight: Radius.circular(35),
              bottomLeft: Radius.circular(35),
              bottomRight: Radius.circular(5)),
          color: Color.fromARGB(255, 255, 253, 253),
          boxShadow: [
            BoxShadow(color:Color.fromARGB(255, 65, 98, 65), spreadRadius:0.5 ,blurRadius: 8 ,offset: Offset(5, 5)),
          ],
        ),
        // color: Colors.black54,
        width: sizeConfig.defaultSize! * 30,
        height: sizeConfig.defaultSize! * 23,
        child: Padding(
          padding: EdgeInsets.all(sizeConfig.defaultSize! * 1),
          child: ListView(
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.only(
                      right: sizeConfig.defaultSize! * 1,
                      left: sizeConfig.defaultSize! * 1),
                  child: Text(
                    ' يوم السبر : ${data.at.split(' ')[0]}   \n\n  عند الساعة : ${data.at.split(' ')[1].substring(0,5)}  \n\n نوع السبر:  ${data.aukaf == 1 ? ' سبر أوقاف ' : ' سبر ترشيحي '} \n\n  الملاحظات : ${data.notes} ',
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ),
              SizedBox(height: sizeConfig.defaultSize! * 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: sizeConfig.defaultSize! * 24,
                    child: DateTime.now().isAfter(DateTime.parse(data.at))
                        ? ElevatedButton(
                            onPressed: () {
                            profile.show_success_students_in_test(context, data.id).then((thenValue){
                              if (thenValue) {
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => (Showsuccesuserintest(SuccessUsers: profile.success_users, FailUsers: profile.fail_users)),),);                              }
                              else{
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('يوجد مشكلة تمنه من الوضول الى هذه الصفحة'),
          backgroundColor: const Color.fromARGB(255, 175, 79, 76),
        ));
                              }
                            });
                            
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                side: BorderSide.none,
                                shape: const StadiumBorder()),
                                  child: const Text(
                              'عرض النتائج',
                              style: TextStyle(color: Colors.white),
                            ),
                        )
                        //another button for get success student action
                        : ElevatedButton(
                            onPressed: () {
                            profile.show_test_accepters(context, data.id).then((thenValue){
                              if (thenValue) {
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => (UserTestListViewAccepters(DataFromApi: profile.TestUseraccepters,)),),);                              }
                              else{
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('يوجد مشكلة تمنه من الوضول الى هذه الصفحة'),
          backgroundColor: const Color.fromARGB(255, 175, 79, 76),
        ));
                              }
                            });
                            
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                side: BorderSide.none,
                                shape: const StadiumBorder()),
                           child: const Text(
                              'عرض المتقدمين',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                  ),
                ],
              ),
              SizedBox(height: sizeConfig.defaultSize! * 2),
              
              userPrivilige != 1
                  ? actionsForAdmins(
                      privilege: userPrivilige,
                      date: data.at,
                      aukaf: data.aukaf,
                      test_id: data.id,
                      methodFromGrandPa: methodFromParent,
                      )
                  : actionsForUsers(aukaf: data.aukaf, date: data.at,test_id: data.id,)
            ],
          ),
        ),
      ),
    );
    });}
}

class actionsForAdmins extends StatefulWidget {
  final int privilege;
  final String date;
  final int aukaf;
  final int test_id;
  final Function(Profile profile) methodFromGrandPa;
   actionsForAdmins(
      {required this.privilege, required this.date, required this.aukaf ,required this.test_id ,required this.methodFromGrandPa});

  @override
  State<actionsForAdmins> createState() => _actionsForAdminsState();
}

class _actionsForAdminsState extends State<actionsForAdmins> {
  GlobalKey<FormState> form_key = GlobalKey<FormState>();
  String notesToAukafTest ='';
  String? note_validator (String? value) {
    if (value == ''){return 'أدخل الملاحظات';}
    return null;
  }
  DateTime selectedDate = DateTime.now();

  TimeOfDay selectedTime = TimeOfDay.now();

 _selectDate(BuildContext context) async {
     DateTime? picked = await showDatePicker(
        context: context,
        helpText: 'إضافة موعد للسبر',
        initialDate: selectedDate, // Refer step 1
        firstDate: DateTime.now(),
        lastDate: DateTime(2035),
        builder:(context, child) {
          return addThemeToDate(context, child);});
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;

      });
  }

  _selectTIme(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
        context: context,
        helpText: 'إضافة وقت للسبر',
        initialTime: selectedTime, // Refer step 1
        builder: (context, child) {
          return addThemeToDate(context, child);});
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedTime = picked;
      });
  }

  addThemeToDate(context,child) {
          return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  secondary: Colors.green,
                  onSecondary: Colors.black,
                  primary:
                      Color.fromARGB(255, 0, 0, 0), // header background color
                  onPrimary: Colors.white, // header text color
                  onSurface: Colors.black, // body text color
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor:
                        Color.fromARGB(255, 13, 90, 7), // button text color
                  ),
                ),
              ),
              child: child,);
        }

  @override
  Widget build(BuildContext context) {
 return Consumer<Profile>(builder: (context, profile, child) {
    return widget.privilege == 3
        ? Column(
            children: [
              SizedBox(
                width: sizeConfig.defaultSize! * 14,
                child: ElevatedButton(
                                  onPressed: () {
                                  
                        profile.delete_test(context, widget.test_id).then((thenValue){
                          if (thenValue) {
                            ////////////////get the tests to update profile data //////////////
              
              widget.methodFromGrandPa.call(profile);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('تم الحذف '),
                        backgroundColor: const Color.fromARGB(255, 175, 79, 76),
                      ));
              
              
              }                              else{
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('يوجد مشكلة تمنع حذف هذا السبرة'),
                        backgroundColor: const Color.fromARGB(255, 175, 79, 76),
                      ));
                          }
                        });
              
                  },
                  
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 169, 62, 62),
                      side: BorderSide.none,
                      shape: const StadiumBorder()),
                  child: const Text('حذف السبر ',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              (DateTime.now().isAfter(DateTime.parse(widget.date)) && widget.aukaf == 0)
                  ? SizedBox(
                      width: sizeConfig.defaultSize! * 20,
                      child: ElevatedButton(
                        onPressed: () {
                         showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  
                  scrollable: true,
                  title: const Text("معلومات السبر"),
                  content: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                      key: form_key,
                      child: Column(
                        children: [
                                          ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: Text(
                      'اختر تاريخ',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Colors.green)),
                  ),
                                  const SizedBox(
                    height: 5,
                  ),
                  ElevatedButton(
                    onPressed: () => _selectTIme(context),
                    child: Text(
                      'اختر الوقت',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Colors.green)),
                  ),
                                                    const SizedBox(
                    height: 5,
                  ),
                        TextFormField(
                          validator: note_validator,
                            onSaved: (newValue){
                              newValue==null?notesToAukafTest='':
                              notesToAukafTest = newValue;} ,
                            decoration: const InputDecoration(
                              labelText: "الملاحظات",
                              icon: Icon(Icons.notes_outlined),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor:Colors.green),
                      child: const Text("إنشاء" ,style: TextStyle(color: Colors.white),),
                      onPressed: () {
                      FormState form_state = form_key.currentState as FormState;
                        form_state.save();
                        if (!form_state.validate()){return;}
                        String parsingDate='${selectedDate.year}-${selectedDate.month}-${selectedDate.day} ${selectedTime.hour}:${selectedTime.minute}';
                       profile.make_aukaf_test_for_success_students(context, widget.test_id, parsingDate, notesToAukafTest).then((thenValue){
                          if (thenValue) {
                            ////////////////get the tests to update profile data //////////////
                      
              widget.methodFromGrandPa.call(profile);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('تم إنشاء السبر  '),
                        backgroundColor: Color.fromARGB(255, 81, 175, 76),
                      ));
              
              
              }                              else{
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('يوجد مشكلة تمنع إنساء سبر اوقاف'),
                        backgroundColor: const Color.fromARGB(255, 175, 79, 76),
                      ));
                          }
                        });
              
                      },
                    ),
                  ],
                );
              },
            );
 
                  },
                  
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            side: BorderSide.none,
                            shape: const StadiumBorder()),
                        child: const Text('إنشاء سبر أوقاف للطلاب الناجحين',
                            style: TextStyle(color: Colors.white)),
                      ),
                    )
                  : const SizedBox(
                      height: 4,
                    )
            ],
          )
        : const SizedBox(height: 5);
  }
    );
  }
}

class actionsForUsers extends StatefulWidget {
  final int aukaf;
  final String date;
  final int test_id;
  const actionsForUsers({required this.aukaf, required this.date,required this.test_id});

  @override
  State<actionsForUsers> createState() => _actionsForUsersState();
}

class _actionsForUsersState extends State<actionsForUsers> {
  bool Accepted = false ;
  @override
  Widget build(BuildContext context) {
    return Consumer<Profile>(builder: (context, profile, child) {
    return (widget.aukaf != 1 && DateTime.now().isBefore(DateTime.parse(widget.date)))
        ? 
        //////////////////////////////////BIg if///////////////////////////////////////////
        Accepted?
        //////////////////////////////////small if////////////////////////////////////
              SizedBox(
                width: sizeConfig.defaultSize! * 14,
                child: ElevatedButton(
                                        onPressed: () {
                                  
                        profile.delete_accepted_test(context, widget.test_id).then((thenValue){
                          if (thenValue) {
                            setState(() {
                              Accepted =false;
                            });
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('تم التقديم '),
                        backgroundColor: Color.fromARGB(255, 76, 175, 81),
                      ));
              
              
              }                              else{
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('يوجد مشكلة تمنع التقديم للسبر'),
                        backgroundColor: const Color.fromARGB(255, 175, 79, 76),
                      ));
                          }
                        });
              
                  },
                  
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 240, 30, 15),
                      side: BorderSide.none,
                      shape: const StadiumBorder()),
                  child: const Text(' حذف التقديم  ',
                      style: TextStyle(color: Colors.white)),
                ),
              )
:      ////////////////////////////////////////small else ////////////////////////
        SizedBox(
                width: sizeConfig.defaultSize! * 14,
                child: ElevatedButton(
                           onPressed: () {
                                  
                        profile.accept_test(context, widget.test_id).then((thenValue){
                          if (thenValue) {
                            setState(() {
                              Accepted =true;
                            });
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('تم التقديم '),
                        backgroundColor: Color.fromARGB(255, 76, 175, 81),
                      ));
              
              
              }                              else{
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('يوجد مشكلة تمنع التقديم للسبر'),
                        backgroundColor: const Color.fromARGB(255, 175, 79, 76),
                      ));
                          }
                        });
              
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 31, 100, 173),
                      side: BorderSide.none,
                      shape: const StadiumBorder()),
                  child: const Text('تقديم للسبر',
                      style: TextStyle(color: Colors.white)),
                ),
              ):
            

///////////////////////////////////////////BIg else//////////////////////////////////////
const SizedBox(
            height: 5,
          ) ;
});
  }
}










