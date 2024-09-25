
import 'package:flutter/material.dart';
import 'package:masjed/core/utils/QuraansoarManage.dart';
import 'package:masjed/data/objects.dart';



class AddHadithHomework extends StatelessWidget {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
final TextEditingController menuController = TextEditingController();
  static List<int> menuItems = Quraansoarmanage.AhadithNumber;
    String hadithNum = '';
  String from = '';
  String to = '';
    homeworkSurahToSend? homeworkForForm;
 

   AddHadithHomework({super.key});
  AddHadithHomework.completedForm({required this.homeworkForForm});
  String? all_validator(String? value) {
    if (value == '') {
      return 'هذا الحقل مطلوب';
    }
    return null;
  }
  @override
  Widget build(BuildContext context) {
  return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
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
          padding: const EdgeInsets.all(15.0),
          child: homeworkForForm == null
              ? Form(
                  key: formKey,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text(
                            'الواجب القادم :    ',
                            textDirection: TextDirection.rtl,
                          ),
                          DropdownMenu<String>(
                            initialSelection: hadithNum,
                            controller: menuController,
                            hintText: "اختر رقم الحديث",
                            requestFocusOnTap: true,
                            enableFilter: true,
                            label: const Text('اختر الحديث'),
                            onSelected: (String? menu) {
                              hadithNum = menu!;
                            
                            },
                            dropdownMenuEntries: menuItems
                                .map<DropdownMenuEntry<String>>((int menu) {
                              return DropdownMenuEntry<String>(
                                  value: menu.toString(), label: menu.toString());
                            }).toList(),
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
                                  from = value!;
                                },
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(19),
                                          bottomRight: Radius.circular(19))),
                                  label: Text(' من السطر '),
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
                                  to = value!;
                                },
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(19),
                                          bottomRight: Radius.circular(19))),
                                  label: Text(' إلى السطر '),
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
                            'الواجب القادم  :    ',
                            textDirection: TextDirection.rtl,
                          ),
                          DropdownMenu<String>(
                            controller: menuController,
                            initialSelection:
                                Quraansoarmanage.soarList[homeworkForForm!.num],
                            hintText: "اختر الحديث",
                            requestFocusOnTap: true,
                            enableFilter: true,
                            label: const Text('اختر الحديث'),
                            onSelected: (String? menu) {
                              hadithNum = menu!;
                         
                            },
                            dropdownMenuEntries: menuItems
                                .map<DropdownMenuEntry<String>>((int menu) {
                              return DropdownMenuEntry<String>(
                                  value: menu.toString(), label: menu.toString());
                            }).toList(),
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
                                initialValue: homeworkForForm!.from.toString(),
                                keyboardType: TextInputType.number,
                                validator: all_validator,
                                onSaved: (value) {
                                  from = value!;
                                },
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(19),
                                          bottomRight: Radius.circular(19))),
                                  label: Text(' من الآية '),
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
                                  to = value!;
                                },
                                initialValue: homeworkForForm!.to.toString(),
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(19),
                                          bottomRight: Radius.circular(19))),
                                  label: Text(' إلى الآية '),
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
        content: Text(' أدخل جميع الحقول قبل الانتقال للحديث  التالي'),
        backgroundColor: const Color.fromARGB(255, 175, 79, 76),
      ));
      return false;
    }
    form.save();

    var myIntfrom = int.parse(from);
    assert(myIntfrom is int);

    var myIntto = int.parse(to);
    assert(myIntto is int);


    homeworkSurahToSend(
            num: int.parse(hadithNum), from: myIntfrom, to: myIntto)
        .dispatch(context);
    return true;
  }



}
