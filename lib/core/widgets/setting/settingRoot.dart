

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:masjed/core/utils/sizeConfig.dart';
import 'package:masjed/core/widgets/setting/changeDetails.dart';
import 'package:masjed/core/widgets/setting/resetPassword.dart';


class settingRoot extends StatelessWidget {
  

  List<Widget>_tabs = [
 changeDetails(),
    Resetpassword(),
   

  ];
  


   settingRoot({
   
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    sizeConfig().init(context);
    return DefaultTabController(
      length:_tabs.length,
      child: Scaffold(

      appBar:
      const  TabBar(
        
          splashBorderRadius: BorderRadius.all(Radius.circular(38)),
          indicatorColor: Colors.green,
          labelColor:   Color.fromARGB(255, 0, 0, 0),
          dividerColor: Color.fromARGB(255, 94, 136, 80) ,
          tabs: [
            
             Tab(icon: Icon(Icons.featured_play_list_outlined), text: 'تغيير التفاصيل'),
             
            Tab(
                icon: Icon(Icons.lock_open_outlined),
                text: ' تغيير كلمة المرور')
       
          ],
        ),
             body: TabBarView(
          children: _tabs,
        ),
    
    ) ,
    );
    
    
    
    
    
    }
    
    }