import 'dart:convert';
import 'dart:developer';


import 'package:flutter/material.dart';
import 'package:masjed/core/utils/sizeConfig.dart';
import 'package:masjed/core/widgets/DownloaddataContextBTN.dart';
import 'package:masjed/data/objects.dart';
import 'package:masjed/screens/admin_screens/ManagmentScreens/SHowTeacherScreen.dart';
import 'package:masjed/screens/admin_screens/latestScreens/LatestsRoot.dart';
import 'package:masjed/screens/user_screens/showUserProfile/ShowUserHome.dart';
import 'package:masjed/screens/user_screens/user%20home/user_home.dart';
import 'package:masjed/screens/user_screens/user_latest.dart';
import 'package:masjed/state/profile.dart';
import 'package:provider/provider.dart';
import 'package:masjed/state/user.dart';

class UserRanking extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Column(
          children: [
            SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: sizeConfig.defaultSize! * 14.5,
                child: Image.asset('images/ranks.jpg', fit: BoxFit.fill),
              ),
            ),
            Expanded(
              child: Scaffold(
                appBar: const TabBar(
                  labelColor: Colors.green,
                  indicatorColor: Colors.green,
                  tabs: [
                    Tab(
                      text: 'الحلقة',
                    ),
                    Tab(
                      text: 'المسجد',
                    ),
                    Tab(
                      text: 'الأساتذة',
                    ),
                  ],
                ),
                body: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  children: [RankView(false), RankView(true), TeachersScreen()],
                ),
              ),
            )
          ],
        ));
  }
}

class RankView extends StatelessWidget {
  final ScrollController controller = ScrollController();
  final bool global;

  RankView(this.global);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
          color: Colors.grey[100],
          border: BorderDirectional(
              start: BorderSide(width: 1.5, color: Colors.black26),
              end: BorderSide(width: 1.5, color: Colors.black26))),
      child: Column(
        children: [
          ListHeader(
            global: global,
          ),
          ListContent(global),
        ],
      ),
    );
  }
}

class ListHeader extends StatelessWidget {
  final bool global;

  const ListHeader({required this.global});
  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context, listen: false);
    return Container(
      decoration: BoxDecoration(
          border: BorderDirectional(
              bottom: BorderSide(width: 0.5, color: Colors.black26))),
      height: sizeConfig.defaultSize! * 5,
      child: (user.privilege != 1 && !global)
          ?
          //////////////////////////////////if//////////////////////////////////
          Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: const BoxDecoration(
                        border: BorderDirectional(
                            end:
                                BorderSide(width: 0.5, color: Colors.black26))),
                    child: const Center(
                      child: Text('الغياب'),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: const BoxDecoration(
                        border: BorderDirectional(
                            end:
                                BorderSide(width: 0.5, color: Colors.black26))),
                    child: const Center(child: Text('المرتبة')),
                  ),
                ),
                Expanded(
                  flex: 12,
                  child: Container(
                    decoration: const BoxDecoration(
                        border: BorderDirectional(
                            end:
                                BorderSide(width: 0.5, color: Colors.black26))),
                    child: const Center(child: Text('الاسم')),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Container(
                    child: const Center(child: Text('مجموع النقاط')),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: const BoxDecoration(
                        border: BorderDirectional(
                            end:
                                BorderSide(width: 0.5, color: Colors.black26))),
                    child: const Center(child: Text('خيارات')),
                  ),
                ),
              ],
            )
          :
          ///////////////////////////////////////else ///////////////////////////////
          Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: const BoxDecoration(
                        border: BorderDirectional(
                            end:
                                BorderSide(width: 0.5, color: Colors.black26))),
                    child: const Center(child: Text('المرتبة')),
                  ),
                ),
                Expanded(
                  flex: 12,
                  child: Container(
                    decoration: const BoxDecoration(
                        border: BorderDirectional(
                            end:
                                BorderSide(width: 0.5, color: Colors.black26))),
                    child: const Center(child: Text('الاسم')),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Container(
                    child: const Center(child: Text('مجموع النقاط')),
                  ),
                ),
              ],
            ),
    );
  }
}

class ListContent extends StatefulWidget {
  final bool global;
  
  ListContent(this.global);

  @override
  State<ListContent> createState() => _ListContentState();
}

class _ListContentState extends State<ListContent> {
  ScrollController controller = ScrollController();
  final TextEditingController reankMenucController = TextEditingController();
  OneUserRank? specificUser;
  int indexOf = -1;
  List<OneUserRank> reankMenu = [];
  List<int> watingStudents =[];
  List<WantingCheckBox> WantingStudentsCheckBox = [];
  static int numberOfBuilds = 0;
  bool logging = true ; 

  @override
  Widget build(BuildContext context) {
    
    initState() {
      specificUser = null;
    }

    // final user = Provider.of<User>(context);
    return Consumer<Profile>(builder: (context, profile, child) {
      
      
      if (!widget.global && numberOfBuilds ==0) {
        numberOfBuilds++;
         WantingStudentsCheckBox=[];
        reankMenu.forEach((item){
          
        WantingStudentsCheckBox.add(WantingCheckBox(checked: false, id: item.user_id));
        
        });

      }
      User user = Provider.of<User>(context, listen: false);
      return Expanded(
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                children: [
                  specificUser == null
                      ? Expanded(
                          child: ListView.builder(
                            itemBuilder: (context, i) {
                              
                              

                              return (!widget.global && user.privilege!=1  )
                                  ? Container(
                                      margin:
                                          EdgeInsets.symmetric(vertical: 2.5),
                                      height: sizeConfig.defaultSize! * 5,
                                      child: Material(
                                        color: Color.fromARGB(255, 88, 241, 93),
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        elevation: 1.0,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: Center(
                                                child: Checkbox(
                                                  
                                                    value: WantingStudentsCheckBox.isEmpty?false:
                                                    WantingStudentsCheckBox.firstWhere((item)=>item.id==reankMenu[i].user_id).checked,

                                                    onChanged: (value) {
                                                      if (value!) {

                                                        watingStudents.add(reankMenu[i].user_id) ; 
                                                      }
                                                      else{
                                                        watingStudents.removeWhere((item)=>reankMenu[i].user_id==item);
                                                      }
                                                          setState(() {
                                                          WantingStudentsCheckBox.firstWhere((item)=>item.id==reankMenu[i].user_id).checked =value;
                                                        });
                                                    }),
                                              ),
                                            ),
                                            Expanded(
                                              child: Center(
                                                  child:
                                                      Text((i + 1).toString())),
                                              flex: 1,
                                            ),
                                            Expanded(
                                              child: Center(
                                                child: Text(
                                                    reankMenu[i].user_name),
                                              ),
                                              flex: 6,
                                            ),
                                            Expanded(
                                              child: Center(
                                                  child: Text(reankMenu[i]
                                                      .points
                                                      .toString())),
                                              flex: 3,
                                            ),
                                            Expanded(
                                              child: Center(
                                                  child:popupmenu(user_id:reankMenu[i].user_id,UpdateParent: UpdateScreen, ) ,
                                              
                                            ),
                                            flex: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(
                                      margin:
                                          EdgeInsets.symmetric(vertical: 2.5),
                                      height: sizeConfig.defaultSize! * 5,
                                      child: Material(
                                        color: (reankMenu[i].user_id ==
                                                    user.id ||
                                                reankMenu[i].teacher_id ==
                                                    user.id)
                                            ? Color.fromARGB(255, 88, 241, 93)
                                            : Color.fromARGB(
                                                255, 255, 255, 255),
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        elevation: 1.0,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Center(
                                                  child:
                                                      Text((i + 1).toString())),
                                              flex: 1,
                                            ),
                                            Expanded(
                                              child: Center(
                                                child: Text(
                                                    reankMenu[i].user_name),
                                              ),
                                              flex: 6,
                                            ),
                                            Expanded(
                                              child: Center(
                                                  child: Text(reankMenu[i]
                                                      .points
                                                      .toString())),
                                              flex: 3,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                            },
                            itemCount: reankMenu.length,
                          ),
                        )
                      : Container(
                          margin: EdgeInsets.symmetric(vertical: 2.5),
                          height: sizeConfig.defaultSize! * 5,
                          child: Material(
                              borderRadius: BorderRadius.circular(5.0),
                              elevation: 1.0,
                              child: indexOf != -1
                                  ? Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Center(
                                              child: Text('${1 + indexOf}')),
                                        ),
                                        Expanded(
                                          flex: 6,
                                          child: Center(
                                            child:
                                                Text(specificUser!.user_name),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Center(
                                              child: Text(specificUser!.points
                                                  .toString())),
                                        ),
                                      ],
                                    )
                                  : Text('البيانات المدخلة غير موجودة'))),
                  (widget.global)
                      ? Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                          child: SizedBox(
                            height: sizeConfig.defaultSize! * 7,
                            child: DropdownMenu<String>(
                              width: sizeConfig.defaultSize! * 15,
                              initialSelection: '',
                              controller: reankMenucController,
                              hintText: "كل الطلاب",
                              requestFocusOnTap: true,
                              enableFilter: true,
                              label: const Text('اختر طالب'),
                              onSelected: (String? menu) {
                                FocusManager.instance.primaryFocus?.unfocus();
                                try {
                                  menu == null
                                      ? specificUser = null
                                      : specificUser = reankMenu.firstWhere(
                                          (element) =>
                                              element.user_name == menu);
                                  menu == null
                                      ? specificUser = null
                                      : indexOf =
                                          reankMenu.indexOf(specificUser!);
                                  print(specificUser);
                                  setState(() {});
                                } catch (e) {}
                              },
                              dropdownMenuEntries: reankMenu
                                  .map<DropdownMenuEntry<String>>(
                                      (OneUserRank User) {
                                return DropdownMenuEntry<String>(
                                    value: User.user_name,
                                    label: User.user_name);
                              }).toList(),
                            ),
                          ),
                        )
                      : SizedBox(),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'تحميل البيانات',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                DownloaddataContextBTN(submit: UpdateScreen, logging: logging, profile: profile, sendedcontext: context),
 ],
            ),


            watingStudents.isEmpty? const SizedBox():
             Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(),
                const Text(
                  'إرسال التفقد',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  child: const Icon(
                    Icons.upload_rounded,
                    color: const Color.fromARGB(255, 0, 0, 0),
                    size: 50,
                  ),
                  onTap: () async {
                    watingStudents;
                    print(watingStudents);
                    print(jsonEncode(watingStudents));
                    
                    await profile
                        .add_wanting_students(context, watingStudents)
                        .then((promiseValue) {

                          
                      if (promiseValue) {
                       
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('تمت اضافة الطلاب الغائبين'),
          backgroundColor: Color.fromARGB(255, 102, 175, 76),
        ));
          
          
                     setState(() {
                      _ListContentState.numberOfBuilds=0;
             watingStudents=[];
           });
           } else {
            
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('مشكلة في اضافة الطلاب الغائبين'),
          backgroundColor: const Color.fromARGB(255, 175, 79, 76),
        ));

           }

                    });
                  
                  
                  },
                ),
              ],
            ),
        

          ],
        ),
      );
    });
  }

  Future<void> UpdateScreen( BuildContext context,Profile profile) async {
    {                     


      setState(() {
        logging = false ;
       
      });
                       print(widget.global);
                             
    
                       await profile
                           .get_rank(context, widget.global)
                           .then((promiseValue) {
                         if (promiseValue) {
                           setState(() {
                              
                             if (profile.RankUsers != null){
                               
                               reankMenu = profile.RankUsers!;
                               // if (!widget.global) {
                               
                               // reankMenu.forEach((item){
    
                               // });
                               // }
                               
                               }
                             else
                               reankMenu = [];
                      _ListContentState.numberOfBuilds=0;
                       logging = true ;
                           });
                         } else {}

                       }
                       
                       );
                     }
  }
}










class popupmenu extends StatelessWidget {
  final int user_id ;
  final Future<void> Function( BuildContext context ,Profile profile ,)UpdateParent;
  const popupmenu({
    required this.user_id,
    required this.UpdateParent,

    super.key,
  });

  @override
  Widget build(BuildContext context) {
    int AuthUserId = Provider.of<User>(context,listen: false).id!;
    int AuthUserPrivilege = Provider.of<User>(context,listen: false).id!;
    return PopupMenuButton(
      
                icon: const Icon(Icons.more_horiz_outlined),
                onSelected: (value) async{
    switch (value) {
      case 1:{
        User user =Provider.of<User>(context , listen: false);
        await user.get_user_info(context,user_id).then((onValue){
if (onValue){
         Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Scaffold(appBar: AppBar(backgroundColor: Colors.green , title:const  Text('الملف الشخصي للطالب ',style: const TextStyle(color: Colors.white , fontWeight: FontWeight.bold),),),  body: ShowuserhomeProfile(userToShowprofile: user.profileUserData!) ,)
          ),
        );

}
else{
     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('مشكلة تمنع الانتقال لهذه الصفحة'),
        backgroundColor: const Color.fromARGB(255, 175, 79, 76),
      ));
}
        });
 
      }
        break;
      case 2:
{
         Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => LatestRoot(user_id: user_id,),
          ),
        );
 
      }
        break;
           case 3:
      {
 Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Scaffold(appBar: AppBar(backgroundColor: Colors.green , title:const  Text('آخر الإنجازات',style: const TextStyle(color: Colors.white , fontWeight: FontWeight.bold),),),  body: UserLatest.forteacher(userId: user_id) ,),
          ),
        );      

        break;
      }
     
      case 4:
      {
        User user =Provider.of<User>(context , listen: false);
        Profile profile =Provider.of<Profile>(context , listen: false);
        await user.leave_student(context,user_id).then((onValue){
          if (onValue){
          UpdateParent.call(context,profile);
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('تم إخراج الطالب من الحلقة'),
        backgroundColor: Color.fromARGB(255, 76, 175, 83),
      ));

}
else{
     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('مشكلة تمنع الانتقال لهذه الصفحة'),
        backgroundColor: const Color.fromARGB(255, 175, 79, 76),
      ));
}
        });
 
      

        break;
      }
      default:
        print('inside default on swich in userList.dartfile line 53');
    }
                },
                itemBuilder: (BuildContext) {
    return   [
      PopupMenuItem(
        child:Text('الملف الشخصي'),
        value: 1,
      ),
      const PopupMenuItem(
        value: 2,
         child: Text('إضافة أخر الإنجازات'),
      ),
             const  PopupMenuItem(
        // ignore: sort_child_properties_last
        child: Text('عرض الإنجاز السابق' ,style: TextStyle(color: Colors.red , fontWeight: FontWeight.bold),),
        value: 3,
      ),
        PopupMenuItem(
        child: Text('إخراج من الحلقة' ,style: TextStyle(color: Colors.red , fontWeight: FontWeight.bold),),
        value: 4,
      ),

    ];
                },
              );
  }
}
