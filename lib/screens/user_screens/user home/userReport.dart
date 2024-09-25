import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:masjed/core/utils/sizeConfig.dart';
import 'package:masjed/core/widgets/DownloaddataContextBTN.dart';
import 'package:masjed/data/objects.dart';
import 'package:masjed/state/profile.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserReport extends StatefulWidget {
  int  user_id = 0;

  UserReport();

  UserReport.forProfile({required this.user_id});

  

  @override
  State<UserReport> createState() => _UserReportState();
}

class _UserReportState extends State<UserReport> {
  bool logging = true ; 
  @override
 initState(){super.initState();
 }
  @override
  Widget build(BuildContext context) {
    


    return Consumer<Profile>(builder: (context, profile, child) {
//when we want to update the data every time the screen opened
      // return FutureBuilder<bool>(
      //     future: addScore, //addscore = profile.get_score(context, Provider.of<User>(context).privilege!, 0);
      //     builder:(context, AsyncSnapshot<bool> snapshot) {
      //     return snapshot.connectionState == ConnectionState.waiting
      //           ? CircularProgressIndicator()
      //           : 
                return Container(
            padding: EdgeInsets.symmetric(vertical:  sizeConfig.defaultSize!*1, horizontal:  sizeConfig.defaultSize!*0.5),
            child: Column(
              children: [
                Card(
                    color: Colors.lightGreen[400],
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal:  sizeConfig.defaultSize!*0.5, vertical:  sizeConfig.defaultSize!*2.5),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                            SizedBox(
                            height:  sizeConfig.defaultSize!*25.5,
                            child: GridView.count(
                              physics: const NeverScrollableScrollPhysics(),
                              childAspectRatio: 1.4,
                              crossAxisCount: 2,
                              children: [
                                PointField('القرآن',profile.q_points, 'images/quran.png'),
                                PointField('الحديث',profile.h_points, 'images/hadith.png'),
                                PointField('الأنشطة',profile.a_points, 'images/activity.png'),
                                PointField('عقوبات',profile.l_points, 'images/penalty.png'),
                              ],
                            ),
                          ),
                          Center(
                            child: Column(
                                children: [
                                  Text('تحميل البيانات'),
                                  DownloaddataContextBTN(submit: DownloadData, logging: logging, profile: profile, sendedcontext: context),

                       ],
                              ),

                            ),
                            ],
                          ),
                          SizedBox(height:  sizeConfig.defaultSize!*1.5),
                          Center(
                            child: Text('مجموع النقاط',
                                style: TextStyle(fontSize:  sizeConfig.defaultSize!*1.7)),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            width:  sizeConfig.defaultSize!*6,
                            height: sizeConfig.defaultSize!*5,
                            decoration: BoxDecoration(
                                color: Colors.lightGreen[300],
                                borderRadius: BorderRadius.circular(100)),
                            child:Center(child: Text('${profile.q_points+profile.a_points+profile.h_points-profile.l_points}' ,style: TextStyle(fontSize:  sizeConfig.defaultSize!*2),),),),
                          
                        ],
                      ),
                    )),
                const SizedBox(height: 10),
                Card(
                    color: Colors.lightGreen[400],
                    child: Padding(
                        padding: EdgeInsets.symmetric(horizontal:  sizeConfig.defaultSize!*0.5, vertical:  sizeConfig.defaultSize!*1),
                        child: Column(children: [
                          Center(
                            child: Text(
                              'الاجزاء التي تم سبرها',
                              style: TextStyle(fontSize:  sizeConfig.defaultSize!*1.8),
                            ),
                          ),
                          const SizedBox(height: 5),
                          SingleChildScrollView(
                            child: SizedBox(
                              height:  sizeConfig.defaultSize!*6.5,
                              child: GridView.count(
                                crossAxisCount: 10,
                                children: chapters(profile.ended_parts==null?[]:profile.ended_parts!),
                              ),
                            ),
                          ),
                        ])))
              ],
            ),
          );
        }
      );
    
  }

  Future<void> DownloadData(BuildContext context, Profile profile) async {
    {
    
                      setState(() {logging = false ;});
                                 int privilege = Provider.of<User>(context,listen: false).privilege!;
    
                                 await profile.get_score(context, privilege, widget.user_id).then((value){
                                  
                                   if(value){
                                    
                                           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
             content: Text('تمت عملية جلب البيانات'),
             backgroundColor: Color.fromARGB(255, 124, 175, 76),
           ));
                                   }else{
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
             content: Text('مشكلة في جلب البيانات'),
             backgroundColor: const Color.fromARGB(255, 175, 79, 76),
           ));
                                   }
                                 });
                                 setState(() {});
                                 logging  =true ;
                               }
  }
}

class PointField extends StatelessWidget {
  String title;
  int value;
  String image_path;

  PointField(this.title, this.value, this.image_path);

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(
        width: sizeConfig.defaultSize!* 6,
        height:  sizeConfig.defaultSize!*6,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Image.asset(image_path),
        ),
      ),
      const SizedBox(height: 1),
      Center(
        child: Text(title),
      ),
      const SizedBox(height: 8),
      Container(
        width:  sizeConfig.defaultSize!*4,
        height:  sizeConfig.defaultSize!*3,
        decoration: BoxDecoration(
            color: Colors.lightGreen[300],
            borderRadius: BorderRadius.circular(100)),
        child: Center(child: Text('$value')),
      )
    ]);
  }
}

class AnimatedNumber extends StatefulWidget {
  final int num;
  final double? font_size;

  AnimatedNumber(this.num, {this.font_size});

  @override
  State<StatefulWidget> createState() => AnimatedNumberState();
}

class AnimatedNumberState extends State<AnimatedNumber>
    with TickerProviderStateMixin {
    
  late final AnimationController controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 1));
  late final Animation<int> animation;

  @override
  void initState() {
   
    controller.addListener(() {
      setState(() {});
    });
    animation = IntTween(begin: 0, end: widget.num).animate(controller);
    controller.forward();
    super.initState();
  }
  

  @override
  Widget build(BuildContext context) {
    setState(() {});
    return Center(
      child: Text(animation.value.toString(),
          style: TextStyle(fontSize: widget.font_size)),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

List<Widget> chapters(List<dynamic> list) {
  List<Widget> widgets = [];
  for (int i = 0; i < 30; i++) {
   bool ColorBool=false;
    for (var l = 0; l < list.length; l++) {
      if(list[l]-1==i){
        ColorBool =true;
        break;
      } 
    }
    widgets.add(Container(
      decoration: BoxDecoration(
        
          color: (ColorBool) ? Colors.green : Colors.blueGrey[100],
          borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.all(2),
      width:  sizeConfig.defaultSize!*2,
      height:  sizeConfig.defaultSize!*2,
      child: Center(
        child: Text((i + 1).toString()),
      ),
    ));

  }
  return widgets;
}

