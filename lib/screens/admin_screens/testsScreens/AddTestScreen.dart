import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:masjed/state/profile.dart';
import 'package:provider/provider.dart';

class AddTestsScreen extends StatefulWidget {
  const AddTestsScreen({super.key});

  @override
  State<AddTestsScreen> createState() => _AddTestsScreenState();
}

class _AddTestsScreenState extends State<AddTestsScreen> {
    GlobalKey<FormState> form_key = GlobalKey<FormState>();
  String notesToAukafTest ='';
  String? note_validator (String? value) {
    if (value == ''){return 'أدخل الملاحظات';}
    return null;
  }
  int dropdownvalue = 3;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  static List<String> items = [
    'ترشيحي ',
    'أوقاف',
  ];
  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
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
        helpText: 'إضافة موعد للسبر',
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
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // -- Form Fields
            Form(
              key: form_key,
              child: Column(
                children: [
                  const Text(
                    " بتاريخ :",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    " ${selectedDate.year} ${selectedDate.month} ${selectedDate.day} ",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    textDirection: TextDirection.ltr,
                  ),
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
                  const Text(
                    "بتوقيت : ",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    " ${selectedTime.hour} : ${selectedTime.minute} ",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    textDirection: TextDirection.ltr,
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
                  const SizedBox(height: 20),
                  TextFormField(

                    validator: note_validator,
                    onSaved: (newValue) {
                      newValue==null?
                      notesToAukafTest='':notesToAukafTest=newValue;
                    },
                    decoration: const InputDecoration(
                        
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(19),
                                bottomRight: Radius.circular(19))),
                        label: Text('ملاحظات'),
                        prefixIcon: Icon(Icons.note_add_sharp, color: Colors.black)),
                  ),
                  const SizedBox(height: 20),
   
// -- Form Submit Button,
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 150,
                    child: ElevatedButton(
                                          onPressed: () {
                      FormState form_state = form_key.currentState as FormState;
                        form_state.save();
                        if (!form_state.validate()){return;}
                        String parsingDate='${selectedDate.year}-${selectedDate.month}-${selectedDate.day} ${selectedTime.hour}:${selectedTime.minute}';
                       profile.add_new_test(context, parsingDate, notesToAukafTest).then((thenValue){
                          if (thenValue) {
                            ////////////////get the tests to update profile data //////////////
              
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
                   
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          side: BorderSide.none,
                          shape: const StadiumBorder()),
                      child: const Text('إضافة',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  });
  
} }
