import 'package:flutter/material.dart';

class sizeConfig{

  static double? screenHight;
  static double? screenWidth;
  static double? defaultSize;
  static Orientation? orientation;

  void init (BuildContext context){
   screenWidth=  MediaQuery.of(context).size.width;
    screenHight= MediaQuery.of(context).size.height;
    orientation =   MediaQuery.of(context).orientation;

    defaultSize = orientation==Orientation.landscape?screenHight !* 0.024 :screenWidth!*0.024;
    print("this is the default size ${defaultSize}");
  }
}