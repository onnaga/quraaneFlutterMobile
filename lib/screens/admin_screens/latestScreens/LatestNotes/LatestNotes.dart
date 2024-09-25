import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:masjed/core/widgets/submitFormButton.dart';
import 'package:masjed/screens/admin_screens/latestScreens/latestActivity/ActCard.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';


class LatestNote extends StatefulWidget {
      final int  userId ;  

  const LatestNote({super.key , required this.userId});
  

  @override
  State<LatestNote> createState() => _LatestNoteState();
}

class _LatestNoteState extends State<LatestNote> {
  String note ='' ;
  String LPoint = '0';
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? noteValidator(String? value) {
    if (value == '') {
      return 'أضف الملاحظة';
    }
    note = value!;
  }

    String? LpointValidator(String? value) {
    if (value == '') {
      return 'أضف النقاط المخصومة ';
    }
    LPoint = value!;
    
    
  }
  @override
  Widget build(BuildContext context) {
    return 
     ListView(
       children: [
         Padding(
          padding: const EdgeInsets.only(top: 15.0, bottom: 150 , left: 15,right: 15),
          child:
          
           

              Container(
                height: 190,
                decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(5),
              topRight: Radius.circular(35),
              bottomLeft: Radius.circular(35),
              bottomRight: Radius.circular(35)),
          color: Color.fromARGB(255, 253, 251, 251),
          boxShadow: [
            BoxShadow(color: Color.fromARGB(255, 175, 102, 76), spreadRadius:0.5 ,blurRadius: 8 ,offset: Offset(5, 5)),
          ],
        ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ListView(
                    children: [
                      
                      Form(
                        key: formKey,
                        child: Column(
                                      children: [
                            const SizedBox(
                              height: 30,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 300,
                                  child: TextFormField(
                                    validator: noteValidator,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(19),
                                              bottomRight: Radius.circular(19))),
                                      label: Text(' إضافة ملاحظة'),
                                      prefixIcon: Icon(
                                        Icons.note_add_rounded,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 190,
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    validator: LpointValidator,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(19),
                                              bottomRight: Radius.circular(19))),
                                      label: Text('النقاط المحذوفة ',style: TextStyle(color: Color.fromARGB(194, 190, 0, 0)),),
                                      prefixIcon: Icon(Icons.delete_forever, color: Color.fromARGB(255, 178, 3, 3)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  
                    
                    ],
                  ),
                ),
              ),
             ),
            

              Padding(
                padding: const EdgeInsets.only(right: 100 , left: 100),
                child: submitFormButton(submit: submit),
              ),
             
            
  
       ],
     );}

  void submit() {

    User user = Provider.of<User>(context, listen: false);

   FormState form = formKey.currentState as FormState;
    if (!form.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(' أدخل جميع الحقول قبل ارسال االمعلومات'),
        backgroundColor: const Color.fromARGB(255, 175, 79, 76),
      ));
     return;
    }
    form.save();

    user.add_latest_notes(
        context, widget.userId,note,LPoint ).then((auth) {
      if (auth) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(milliseconds: 1500),
            closeIconColor: Colors.white,
            showCloseIcon: true,
            backgroundColor: Colors.green,
            content: Text(
              ' تم إضافة البيانات',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(milliseconds: 1500),
            closeIconColor: Colors.white,
            showCloseIcon: true,
            backgroundColor: Colors.redAccent,
            content: Text(
              'توجد مشكلة في الإضافة',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
      return auth;
    });
  }




}


