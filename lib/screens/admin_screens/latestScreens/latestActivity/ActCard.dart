import 'package:flutter/material.dart';
import 'package:masjed/data/objects.dart';
import 'package:masjed/screens/admin_screens/latestScreens/latestActivity/ActCard.dart';


class ActCard extends StatelessWidget {

   ActCard({super.key});
      final GlobalKey<FormState> formKey = GlobalKey<FormState>();

final TextEditingController menuController = TextEditingController();
  
    String ActName = '';
  String mark = '';
  String point = '';
    activitiesToSend? activityForForm;
 
  ActCard.completedForm({required this.activityForForm});
  String? all_validator(String? value) {
    if (value == '') {
      return 'هذا الحقل مطلوب';
    }
    return null;
  }


  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(35),
              topRight: Radius.circular(35),
              bottomLeft: Radius.circular(35),
              bottomRight: Radius.circular(5)),
          color: Color.fromARGB(255, 253, 251, 251),
          boxShadow: [
            BoxShadow(color: Color.fromARGB(255, 65, 98, 65), spreadRadius:0.5 ,blurRadius: 8 ,offset: Offset(5, 5)),
          ],
        ),
        
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: activityForForm == null
              ? Form(
                  key: formKey,
                  child: Column(
                    children: [
                      Row(
                        
                        children: [
                          const Text(
                            'اسم النشاط :    ',
                            textDirection: TextDirection.rtl,
                          ),
                          
                         SizedBox(
                              width: 40,
                              height: 70,
                            ),
                        


                            Container(
                              width: 190,
                              child: TextFormField(
                                
                                validator: all_validator,
                                onSaved: (value) {
                                  ActName = value!;
                                },
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(19),
                                          bottomRight: Radius.circular(19))),
                                  label: Text(' اسم النشاط '),
                                  prefixIcon: Icon(
                                    Icons.format_list_numbered_outlined,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                           
                          ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 190,
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                validator: all_validator,
                                onSaved: (value) {
                                  mark = value!;
                                },
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(19),
                                          bottomRight: Radius.circular(19))),
                                  label: Text(' التقييم من 100 '),
                                  prefixIcon: Icon(
                                    Icons.format_list_numbered_outlined,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 40,
                              height: 70,
                            ),
                            Container(
                              width: 190,
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                validator: all_validator,
                                onSaved: (value) {
                                  point = value!;
                                },
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(19),
                                          bottomRight: Radius.circular(19))),
                                  label: Text(' النقاط المكتسبة '),
                                  prefixIcon: Icon(
                                      Icons.format_list_numbered_outlined,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
  ],
                  ),
                )
              :
              //////////x//////////////////////////////////////else //////////////////////////
              Form(
                  key: formKey,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text(
                            'اسم النشاط   :    ',
                            textDirection: TextDirection.rtl,
                          ),

                          Container(
                              width: 190,
                              child: TextFormField(
                                initialValue: activityForForm!.name,
                                
                                validator: all_validator,
                                onSaved: (value) {
                                  ActName = value!;
                                },
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(19),
                                          bottomRight: Radius.circular(19))),
                                  label: Text(' اسم النشاط '),
                                  prefixIcon: Icon(
                                    Icons.format_list_numbered_outlined,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            
            
            ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 190,
                              child: TextFormField(
                                initialValue: activityForForm!.mark.toString(),
                                keyboardType: TextInputType.number,
                                validator: all_validator,
                                onSaved: (value) {
                                  mark = value!;
                                },
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(19),
                                          bottomRight: Radius.circular(19))),
                                  label: Text(' التقييم من 100 '),
                                  prefixIcon: Icon(
                                    Icons.format_list_numbered_outlined,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 40,
                              height: 70,
                            ),
                            Container(
                              width: 190,
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                validator: all_validator,
                                onSaved: (value) {
                                  point = value!;
                                },
                                initialValue: activityForForm!.point.toString(),
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(19),
                                          bottomRight: Radius.circular(19))),
                                  label: Text('  النقاط المكتسبة '),
                                  prefixIcon: Icon(
                                      Icons.format_list_numbered_outlined,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
     ],
                  ),
                ),
        ),
      ),
    );
  }

  
  bool submit(BuildContext context) {
    FormState form = formKey.currentState as FormState;
    if (!form.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(' أدخل جميع الحقول قبل الانتقال للنشاط التالي'),
        backgroundColor: const Color.fromARGB(255, 175, 79, 76),
      ));
      return false;
    }
    form.save();

    var myIntMark = int.parse(mark);
    assert(myIntMark is int);

    var myIntpoint = int.parse(point);
    assert(myIntpoint is int);


    activitiesToSend(
            name: ActName, mark: myIntMark, point: myIntpoint)
        .dispatch(context);
    return true;
  }

}

