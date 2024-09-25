

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:masjed/core/utils/QuraansoarManage.dart';
import 'package:masjed/data/objects.dart';
import 'package:masjed/state/profile.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';

class UserTestListViewAccepters extends StatelessWidget {
  
   
   final List<TestUserAccepters>DataFromApi;
   bool isTouching =false;

  UserTestListViewAccepters({required this.DataFromApi});

  @override
  Widget build(BuildContext context) {
    int ? userPrivilige = Provider.of<User>(context,listen: false).privilege;
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.green, title: Text("الطلاب المتقدمون للسبر",style: TextStyle(color: Colors.white , fontWeight: FontWeight.bold),),),

      body: DataFromApi.isEmpty? Center(child: Text("لا يوجد متقدمين بعد ....",style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0) , fontWeight: FontWeight.bold,fontSize: 40),),) : ListView.builder(
      itemCount: DataFromApi.length,
      itemBuilder: (context, index) {
        return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.green, spreadRadius: 0.1),
          ],
        ),
          height:userPrivilige==1?150:350,
          child: Padding(
            padding: const EdgeInsets.only(top: 30),
            child: usersList(
              UserTestInfo: DataFromApi[index],
              privilege: userPrivilige!,
            ),
          ),
        );
      },
    )
   ,
    );
    
 }
}



class usersList extends StatefulWidget {
  static List<String> menuItems = Quraansoarmanage.AzaaList;
  TestUserAccepters UserTestInfo;
  int privilege;
  usersList({required this.UserTestInfo ,required this.privilege});

  @override
  State<usersList> createState() => _usersListState();
}

class _usersListState extends State<usersList> {
  GlobalKey<ChaptersState> chapters_key = GlobalKey<ChaptersState>();

  bool busy = false;

    GlobalKey<FormState> form_key = GlobalKey<FormState>();



final TextEditingController menuController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String ? notes ;
    String ? Rating;
    return 
    widget.privilege==1?
    Padding(
      padding: const EdgeInsets.all(3.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
             crossAxisAlignment: CrossAxisAlignment.start,
              children: [
        
                    Row(
                      
                      children: [
                        Text(
                          " اسم الطالب : ${widget.UserTestInfo.user_name} ",
                          textDirection: TextDirection.rtl,
                          style: TextStyle(fontWeight: FontWeight.bold ,fontSize:20 ),
                        ),
                                             const SizedBox(
              width:100,
            ),
                                      Text(
                      " التقدير : ${widget.UserTestInfo.rating} ",
                      textDirection: TextDirection.rtl,
                      style: TextStyle(fontWeight: FontWeight.bold ,fontSize:20 ),
                    ),
        
                      ],
                    ),
        
        
                                  Text(
                      "ارقام الأجزاء : ${widget.UserTestInfo.the_part_to_test_in} ",
                      textDirection: TextDirection.rtl,
                      style: TextStyle(color: const Color.fromARGB(255, 109, 109, 109),fontWeight: FontWeight.bold ,fontSize:20 ),
                    ),
                  
                 
                    Text(
                      "الملاحظات : ${widget.UserTestInfo.notes} ",
                      textDirection: TextDirection.rtl,
                      style: TextStyle(color: const Color.fromARGB(255, 109, 109, 109)),
                    ),
                  
              
              ],
            ),
            
           ],
        ),
      ),
    ): 
    //////////////////////////////////////else///////////////////////////////////
   Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(5),
              topRight: Radius.circular(35),
              bottomLeft: Radius.circular(5),
              bottomRight: Radius.circular(5)),
          color: Color.fromARGB(255, 255, 255, 255),
          boxShadow: [
            BoxShadow(color: Colors.green, spreadRadius: 3),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Form(
             key: form_key,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  
                   SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                     child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Text(
                          'اسم الطالب : ${widget.UserTestInfo.user_name}',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(fontWeight: FontWeight.bold,fontSize: 19),
                                           ),
                                           const SizedBox(
            width:100,
          ),
                                           Text(
                          'الأجزاء: ${widget.UserTestInfo.the_part_to_test_in}',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(fontWeight: FontWeight.bold,fontSize: 19),
                                           ),
                       ],
                     ),
                   ),
                  const SizedBox(
                    height: 10,
                  ),
                                  Text(
                                   ' التقييم : ${widget.UserTestInfo.rating}',
                                   textDirection: TextDirection.rtl,
                                   style: TextStyle(fontWeight: FontWeight.bold,fontSize: 19),
                                                    ),
                                                    const SizedBox(
                    height: 10,
                  ),
                       Text(
                        'الملاحظات:  ${widget.UserTestInfo.notes}',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(fontWeight: FontWeight.bold,fontSize: 19),
                                         ),
                                           const SizedBox(
                    height: 10,
                  ),
                   Chapters(key: chapters_key),
                                   const SizedBox(
                    height: 10,
                  ),
                  Container(
                                        width: 190,
                                        child: TextFormField(
                                          validator: validator,
                                           onSaved: (value){notes = value;},
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(19),
                                                    bottomRight: Radius.circular(19))),
                                            label: Text(' الملاحظات '),
                                            prefixIcon: Icon(Icons.note_add_outlined,
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                  const SizedBox(
                    height: 10,
                  ),
                                      Container(
                                        
                        width: 190,
                        child: TextFormField(
                          textDirection:  TextDirection.rtl,
                          validator: validator,
                           onSaved: (value){Rating = value;},
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(19),
                                    bottomRight: Radius.circular(19))),
                            label: Text(' التقييم '),
                            prefixIcon: Icon(
                              Icons.rate_review_outlined,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
              
                      // -- Form Submit Button
                      SizedBox(
                        width: 100,
                        child: ElevatedButton(
                          onPressed: () async {
                            Profile profile= Provider.of<Profile>(context,listen: false);
                            FormState form_state = form_key.currentState as FormState;
                            ChaptersState chapter_state = chapters_key.currentState as ChaptersState;
                            if (!form_state.validate()){return;}
                            form_state.save();
                            setState(() {busy = true;});
                            List<int> chapters = chapter_state.get_chapters();

profile.update_test_accepter_data(context,widget.UserTestInfo.test_id , widget.UserTestInfo.user_id,chapters,Rating!,notes!).then((auth){
                              if (auth) {
                                debugger();

                           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("لقد تم تعديل البيانات"),
          backgroundColor: Color.fromARGB(255, 83, 175, 76),
        ));
        widget.UserTestInfo=TestUserAccepters(notes: notes!, test_id: widget.UserTestInfo.test_id , user_id: widget.UserTestInfo.user_id, the_part_to_test_in: chapters.toString(), rating: Rating!, user_name: widget.UserTestInfo.user_name);
                                  setState(() {busy = false;});
}
                              else {
                                debugger();
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("لم يتم التعديل لمشكلة ما"),
          backgroundColor: const Color.fromARGB(255, 175, 79, 76),
        ));
        setState(() {busy = false;});
                              }
                            });
                         
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              side: BorderSide.none,
                              shape: const StadiumBorder()),
                          child:  (busy) ?  const SizedBox(width: 25,height: 25,child: CircularProgressIndicator(color: Colors.white,strokeWidth: 2,)) :  const Text('تعديل', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    
              ],
              ),
            ),
          ),
        ),
      ),
    );
}

 String? validator (String? value) {
    if (value == ''){return 'ادخل جميع الحقول';}
    return null;
  }
}
    
  


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
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(45),border: Border.all(width: 1,color: Colors.green)),
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
        child: Text('أجزاء السبر ',style: TextStyle(color: Colors.green),),
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
