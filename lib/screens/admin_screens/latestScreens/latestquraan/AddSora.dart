import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:masjed/core/utils/QuraansoarManage.dart';
import 'package:masjed/data/objects.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';

class AddSora extends StatelessWidget {
  final TextEditingController menuController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String SoraValue = "الفاتحة";
  int SoraNum = 0;
  String from = '';
  String to = '';
  String mark = '';
  String points = '';
  endedSurahToSend? sorahForForm;
  static List<String> menuItems = Quraansoarmanage.soarList;
  AddSora({
    super.key,
  });
  AddSora.completedForm({required this.sorahForForm});
  String? all_validator(String? value) {
    if (value == '') {
      return 'هذا الحقل مطلوب';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            BoxShadow(color:Color.fromARGB(255, 65, 98, 65), spreadRadius:0.5 ,blurRadius: 8 ,offset: Offset(5, 5)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: sorahForForm == null
              ? Form(
                  key: formKey,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text(
                            'السورة المسمعة :    ',
                            textDirection: TextDirection.rtl,
                          ),
                          DropdownMenu<String>(
                            initialSelection: SoraValue,
                            controller: menuController,
                            hintText: "اختر السورة",
                            requestFocusOnTap: true,
                            enableFilter: true,
                            label: const Text('اختر السورة'),
                            onSelected: (String? menu) {
                              SoraValue = menu!;
                              SoraNum =
                                  Quraansoarmanage.soarList.indexOf(SoraValue);
                              print(SoraValue);
                            },
                            dropdownMenuEntries: menuItems
                                .map<DropdownMenuEntry<String>>((String menu) {
                              return DropdownMenuEntry<String>(
                                  value: menu, label: menu);
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
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 190,
                              child: TextFormField(
                                onSaved: (value) {
                                  mark = value!;
                                },
                                keyboardType: TextInputType.number,
                                validator: all_validator,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(19),
                                          bottomRight: Radius.circular(19))),
                                  label: Text(' التقييم من 100'),
                                  prefixIcon: Icon(Icons.star_half,
                                      color: Colors.black),
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
                                onSaved: (value) {
                                  points = value!;
                                },
                                keyboardType: TextInputType.number,
                                validator: all_validator,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(19),
                                          bottomRight: Radius.circular(19))),
                                  label: Text('النقاط المستحقة '),
                                  prefixIcon:
                                      Icon(Icons.add_task, color: Colors.black),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              :
              ////////////////////////////////////////////////else //////////////////////////
              Form(
                  key: formKey,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text(
                            'السورة المسمعة :    ',
                            textDirection: TextDirection.rtl,
                          ),
                          DropdownMenu<String>(
                            controller: menuController,
                            initialSelection:
                                Quraansoarmanage.soarList[sorahForForm!.num],
                            hintText: "اختر السورة",
                            requestFocusOnTap: true,
                            enableFilter: true,
                            label: const Text('اختر السورة'),
                            onSelected: (String? menu) {
                              SoraValue = menu!;
                              SoraNum =
                                  Quraansoarmanage.soarList.indexOf(SoraValue);
                              print(SoraValue);
                            },
                            dropdownMenuEntries: menuItems
                                .map<DropdownMenuEntry<String>>((String menu) {
                              return DropdownMenuEntry<String>(
                                  value: menu, label: menu);
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
                                initialValue: sorahForForm!.from.toString(),
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
                                initialValue: sorahForForm!.to.toString(),
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
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 190,
                              child: TextFormField(
                                initialValue: sorahForForm!.mark.toString(),
                                onSaved: (value) {
                                  mark = value!;
                                },
                                keyboardType: TextInputType.number,
                                validator: all_validator,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(19),
                                          bottomRight: Radius.circular(19))),
                                  label: Text(' التقييم من 100'),
                                  prefixIcon: Icon(Icons.star_half,
                                      color: Colors.black),
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
                                initialValue: sorahForForm!.point.toString(),
                                onSaved: (value) {
                                  points = value!;
                                },
                                keyboardType: TextInputType.number,
                                validator: all_validator,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(19),
                                          bottomRight: Radius.circular(19))),
                                  label: Text('النقاط المستحقة '),
                                  prefixIcon:
                                      Icon(Icons.add_task, color: Colors.black),
                                ),
                              ),
                            ),
                          ],
                        ),
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
        content: Text(' أدخل جميع الحقول قبل الانتقال للسورة التالية'),
        backgroundColor: const Color.fromARGB(255, 175, 79, 76),
      ));
      return false;
    }
    form.save();

    var myIntfrom = int.parse(from);
    assert(myIntfrom is int);

    var myIntto = int.parse(to);
    assert(myIntto is int);

    var myIntmark = int.parse(mark);
    assert(myIntmark is int);

    var myIntpoints = int.parse(points);
    assert(myIntpoints is int);
    endedSurahToSend(
            num: SoraNum, from: myIntfrom, to: myIntto, mark: myIntmark, point: myIntpoints)
        .dispatch(context);
    return true;
  }


}
