

import 'package:flutter/material.dart';
import 'package:masjed/core/utils/sizeConfig.dart';
import 'package:masjed/state/profile.dart';

class DownloaddataBTN extends StatefulWidget {
  void Function(Profile profile) submit;
  bool logging;
Profile profile ;

  DownloaddataBTN({required this.submit,required this.logging ,required this.profile });

  @override
  State<DownloaddataBTN> createState() => _DownloaddataBTNState();
}

class _DownloaddataBTNState extends State<DownloaddataBTN> {
  @override
  Widget build(BuildContext context) {
    return  GestureDetector(
                              
                        onTap:(){
                          widget.submit(widget.profile);
                        },
            child: (widget.logging) ?                          
                           Icon(Icons.download_for_offline_outlined,color: const Color.fromARGB(255, 0, 0, 0),size: 50,)
                :
           SizedBox(
              width: sizeConfig.defaultSize!*3.5,
              height: sizeConfig.defaultSize!*3.5,
              child:const CircularProgressIndicator(color: Color.fromARGB(255, 0, 0, 0),strokeWidth: 2,),
            )
        );
    
  }
}