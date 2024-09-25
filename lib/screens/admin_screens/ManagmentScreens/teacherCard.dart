
import 'package:flutter/material.dart';
import 'package:masjed/state/profile.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';

class teacherCard extends StatelessWidget {
   Function(Profile profile) updateScreen;
  Map<String, dynamic>? data;
  teacherCard({required this.data ,required this.updateScreen});
  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context,listen: false);
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: 
      (user.id == data?['id'] || user.teache_name == data?['name']) ? 
      //////////////////////////////////if//////////////////////////////////
      Container(

        decoration:  const BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(35),
              topRight: Radius.circular(35),
              bottomLeft: Radius.circular(35),
              bottomRight: Radius.circular(5)),
          color:  Color.fromARGB(255, 253, 251, 251),
          boxShadow: [
            BoxShadow(color:Color.fromARGB(255, 30, 65, 30), spreadRadius:2.5 ,blurRadius: 10 ,),
          ],
        ),

        // color: Colors.black54,
        width: 300,
        height: 290,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
              
                Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: Stack(
                    children: [
                      SizedBox(
                        width: 70,
                        height: 70,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: const Image(
                                image: AssetImage('images/avatar.png'))),
                      ),
                    ],
                  ),
                ),
               const SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                  
                    children: [
                      Text(
                        'الرقم الخاص:  ${data?['id']} \n \n الاسم:  ${data?['name']} \n\n الرقم:  ${data?['phone_number']}  ',
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                      ),
                      SizedBox(width:80 ,),
                      Text(
                        ' العمر: ${data?['age']} \n\n الصلاحية:  ${data?['privilege'] == 3 ? 'استاذ مدير' : 'استاذ مسمع'}\n\n  تاريخ الإنضمام : ${data?['created_at'].split('T')[0]}  ',
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                ),
               
               const SizedBox(height: 20),
                
                user.privilege==3?
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width:140,
                      child: ElevatedButton(
                        onPressed: () {
                          user.Delete_user(context, data?['id'])
                                  .then((auth){
        if (auth) {
                  Profile profile = Provider.of<Profile>(context,listen: false);
                  updateScreen.call(profile);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const  SnackBar(
                        duration: Duration(milliseconds: 1500),
                        closeIconColor: Colors.white,
                        showCloseIcon: true,
                        backgroundColor: Color.fromARGB(255, 175, 76, 76),
                        content: Text(
                          ' تم حذف الاستاذ',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
        }
        else {
          ScaffoldMessenger.of(context).showSnackBar(
                      const  SnackBar(
                        duration: Duration(milliseconds: 1500),
                        closeIconColor: Colors.white,
                        showCloseIcon: true,
                        backgroundColor: Colors.redAccent,
                        content: Text(
                          'توجد مشكلة في الحذف',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );

        }
        return auth;
      });
    
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 240, 30, 15),
                            side: BorderSide.none,
                            shape: const StadiumBorder()),
                        child: const Text('حذف الأستاذ',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
             
                  ],
                ):const SizedBox(),
              ],
            ),
          ),
        ),
      ):   
      
      ////////////////////////////////////////////////else/////////////////////////////////
        Container(

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
        // color: Colors.black54,
        width: 300,
        height: 290,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
              
                Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: Stack(
                    children: [
                      SizedBox(
                        width: 70,
                        height: 70,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: const Image(
                                image: AssetImage('images/avatar.png'))),
                      ),
                    ],
                  ),
                ),
               const SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                  
                    children: [
                      Text(
                        'الرقم الخاص:  ${data?['id']} \n \n الاسم:  ${data?['name']} \n\n الرقم:  ${data?['phone_number']}  ',
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                      ),
                      SizedBox(width:80 ,),
                      Text(
                        ' العمر: ${data?['age']} \n\n الصلاحية:  ${data?['privilege'] == 3 ? 'استاذ مدير' : 'استاذ مسمع'}\n\n  تاريخ الإنضمام : ${data?['created_at'].split('T')[0]}  ',
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                ),
               
               const SizedBox(height: 20),
                
                user.privilege==3?
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width:140,
                      child: ElevatedButton(
                        onPressed: () {
                          user.Delete_user(context, data?['id'])
                                  .then((auth){
        if (auth) {
                  Profile profile = Provider.of<Profile>(context,listen: false);
                  updateScreen.call(profile);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const  SnackBar(
                        duration: Duration(milliseconds: 1500),
                        closeIconColor: Colors.white,
                        showCloseIcon: true,
                        backgroundColor: Color.fromARGB(255, 175, 76, 76),
                        content: Text(
                          ' تم حذف الاستاذ',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
        }
        else {
          ScaffoldMessenger.of(context).showSnackBar(
                      const  SnackBar(
                        duration: Duration(milliseconds: 1500),
                        closeIconColor: Colors.white,
                        showCloseIcon: true,
                        backgroundColor: Colors.redAccent,
                        content: Text(
                          'توجد مشكلة في الحذف',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );

        }
        return auth;
      });
    
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 240, 30, 15),
                            side: BorderSide.none,
                            shape: const StadiumBorder()),
                        child: const Text('حذف الأستاذ',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
             
                  ],
                ):const SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
