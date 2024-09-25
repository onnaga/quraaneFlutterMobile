import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:masjed/core/utils/QuraansoarManage.dart';
import 'package:masjed/data/objects.dart';
import 'package:masjed/state/profile.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';

class Showsuccesuserintest extends StatelessWidget {

   final List<TestUserAccepters>SuccessUsers;
    final List<TestUserAccepters>FailUsers;
   bool isTouching =false;
  Showsuccesuserintest({required this.SuccessUsers ,required this.FailUsers});

  @override
  Widget build(BuildContext context) {


    int ? userPrivilige = Provider.of<User>(context,listen: false).privilege;
       List<Widget> _tabs = [
      SuccessUsersScreen(SuccessUsersList: SuccessUsers, userPrivilige: userPrivilige),
      FailUsersScreen(FailUsersList: FailUsers, userPrivilige: userPrivilige)
  ];
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: const TabBar(
          splashBorderRadius: BorderRadius.all(Radius.circular(38)),
          indicatorColor: Colors.green,
          labelColor:  Color.fromARGB(255, 0, 0, 0),
          dividerColor:Color.fromARGB(255, 94, 136, 80) ,
          tabs: [
            Tab(icon: Icon(Icons.add_chart), text: 'الناجحين'),
           Tab(
                icon: Icon(Icons.people_alt_outlined),
                text: 'الغير ناجحين'),
  
          ],
        ),
        body: TabBarView(
          children: _tabs,
        ),
      ),
    );
    
 }
}

class SuccessUsersScreen extends StatelessWidget {
  const SuccessUsersScreen({
    super.key,
    required this.SuccessUsersList,
    required this.userPrivilige,
  });

  final List<TestUserAccepters> SuccessUsersList;
  final int? userPrivilige;

  @override
  Widget build(BuildContext context) {
    return  SuccessUsersList.isEmpty? Center(child: Text("لا يوجد طلاب ناجحين ....",style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0) , fontWeight: FontWeight.bold,fontSize: 40),),) : 
      //////////////////////////////////else //////////////////////////////////
         ListView.builder(
    itemCount: SuccessUsersList.length,
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
            UserTestInfo: SuccessUsersList[index],
            privilege: userPrivilige!,
          ),
        ),
      );
    },
        );
  
    
    
    
    
}
}





class FailUsersScreen extends StatelessWidget {
  const FailUsersScreen({
    super.key,
    required this.FailUsersList,
    required this.userPrivilige,
  });

  final List<TestUserAccepters> FailUsersList;
  final int? userPrivilige;

  @override
  Widget build(BuildContext context) {
    return   FailUsersList.isEmpty? Center(child: Text("لا يوجد طلاب ناجحين ....",style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0) , fontWeight: FontWeight.bold,fontSize: 40),),) : 
      //////////////////////////////////else //////////////////////////////////
         ListView.builder(
    itemCount: FailUsersList.length,
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
            UserTestInfo: FailUsersList[index],
            privilege: userPrivilige!,
          ),
        ),
      );
    },
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
                            if (!form_state.validate()){return;}
                            form_state.save();
                            setState(() {busy = true;});

profile.update_test_accepter_data(context,widget.UserTestInfo.test_id , widget.UserTestInfo.user_id,[],Rating!,notes!).then((auth){
                              if (auth) {
                                debugger();

                           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("لقد تم تعديل البيانات"),
          backgroundColor: Color.fromARGB(255, 83, 175, 76),
        ));
        widget.UserTestInfo=TestUserAccepters(notes: notes!, test_id: widget.UserTestInfo.test_id , user_id: widget.UserTestInfo.user_id, the_part_to_test_in:[].toString(), rating: Rating!, user_name: widget.UserTestInfo.user_name);
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
    
  

