


import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';


//         "id": 2,
//         "test_id": 1,
//         "user_id": 11,
//         "the_part_to_test_in": "0",
//         "rating": 0,
//         "notes": "0",
//         "user_name": "o",
//         "test_date": "2025-10-02 09:30:00"




class TestUserAccepters {
  final int test_id;
  final int user_id;
  final String user_name;
  final String notes;
final String the_part_to_test_in;
  final String rating;
  TestUserAccepters({required this.notes,required this.test_id,required this.user_id,required this.the_part_to_test_in,required this.rating,required this.user_name});
  TestUserAccepters.fromJson(Map<String, dynamic> json)
      : test_id = json['test_id'] as int,
        user_id = json['user_id'] as int,
        user_name = json['user_name'] as String,
        notes = json['notes'] as String,
        the_part_to_test_in = json['the_part_to_test_in'] as String,
        rating = json['rating'].toString();
}



class UserToShowProfile {
   late  int id;
 late    int age;
 late    String name;
 late    String phone_number; 
 late int privilege;
 late   String photo_hash;
   String ? teache_name = null;
  
  UserToShowProfile({required this.id,required this.age,required this.name,required this.teache_name,required this.phone_number,required this.photo_hash ,required this.privilege});
  UserToShowProfile.fromJson(Map<String, dynamic> json){
      id = json['id'] as int;
        age = json['age'] as int;
        name = json['name'] as String;
        teache_name = json['teache_name'] as String;
        privilege = json['privilege'] as int;
        phone_number = json['phone_number'] as String;
        photo_hash = json['photo_hash'].toString();

  }

}


class reciveLatest {
  List<dynamic>? quran =[];
  List<dynamic>? quranHomework=[];
  List<dynamic>?  hadith=[];
  List<dynamic>?  hadithHomework=[];
  List<dynamic> ? activities=[];
  String? note;
  String ? LPoints;
  String?createdAt = '';

  reciveLatest.fromJson(Map<String, dynamic> json){
        quran =json['quran']==null? []:jsonDecode(json['quran']);
        hadith =json['hadith']==null? []: jsonDecode(json['hadith']);
        quranHomework = json['q_homework']==null? []:jsonDecode(json['q_homework']);
        hadithHomework =json['h_homework']==null? []: jsonDecode(json['h_homework']);
        activities = json['activitis']==null? []:jsonDecode(json['activitis']);
        createdAt= json['updated_at'] ?? json['created_at'];
        note = json['note']==null ? 'لا يوجد ملاحظة مضافة' : jsonDecode(json['note'])['note'] ;
        debugger();
        LPoints = json['note']==null ? "0" :jsonDecode(json['note'])['LPoints'];
        debugger();
}
}

class TestData {


  final int id;
  final String at;
final String notes;
  final int aukaf;

  TestData({required this.notes,required this.aukaf,required this.at,required this.id});

  TestData.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        at = json['at'] as String,
        notes = json['notes'] as String,
        aukaf = json['aukaf'] as int;
}



class WantingCheckBox {


   int id;
   bool checked;

  WantingCheckBox({required this.checked,required this.id});

}


class OneUserRank {

   late int user_id;
   late int teacher_id;
   late String user_name;
   late int points;

  OneUserRank({required this.user_id,required this.user_name,required this.points,required this.teacher_id});

  OneUserRank.fromJson(Map<String, dynamic> json)
  {

      user_id = json['user_id'] as int;
      if (json['teacher_id']==null) {
         teacher_id =0;
      }else{
      teacher_id = json['teacher_id'] as int;
      }
        user_name = json['user_name'] as String;
        points = json['points'] as int;
      
  }

        
}
class Points {
  final int q_points;
  final int h_points;
  final int a_points;
  final int l_points;

  Points({required this.q_points,required this.h_points,required this.a_points,required this.l_points});

  Points.fromJson(Map<String, dynamic> json)
      : q_points = json['q_points'] as int,
        h_points = json['h_points'] as int,
        a_points = json['a_points'] as int,
        l_points = json['l_points'] as int;
}


class User_Notification {
  final DateTime date;
  final String sender;
  final String message;
  final bool read;

  const User_Notification({required this.date , required this.sender , required this.message , required this.read});

  User_Notification.fromJson(Map<String, dynamic> json)
      : date = json['date'] as DateTime,
        sender = json['sender'] as String,
        message = json['message'] as String,
        read = json['read'] as bool;


  Map<String, dynamic> toJson() => {
    'date': date,
    'sender': sender,
    'message': message,
    'read': read
  };

}


class Activities {
  final String details;
  final int points;
  const Activities({required this.details , required this.points});

  Activities.fromJson(Map<String, dynamic> json)
      : details = json['details'] as String,
        points = json['points'] as int;

  Map<String, dynamic> toJson() => {
    'details': details,
    'point': points,
  };
}




class endedSurah {
  final int num;
  final int from;
  final int to;
  final int mark;
  final int points;
 

  endedSurah({required this.num , required this.from , required this.to , required this.mark , required this.points});
  Map<String, dynamic> toJson() => {
    'num': num,
    'from': from,
    'to': to,
    'mark': mark,
    'points': points
  };


}

class endedSurahToSend extends Notification {
  final int num;
  final int from;
  final int to;
  final int mark;
  final int point;
 

  endedSurahToSend({required this.num , required this.from , required this.to , required this.mark , required this.point});
  Map<String, dynamic> toJson() => {
    'num': num,
    'from': from,
    'to': to,
    'mark': mark,
    'point': point
  };
}

class homeworkSurahToSend extends Notification {
  final int num;
  final int from;
  final int to;

 

  homeworkSurahToSend({required this.num , required this.from , required this.to ,});
  Map<String, dynamic> toJson() => {
    'num': num,
    'from': from,
    'to': to,

  };


}



class activitiesToSend extends Notification {
  final String name;
  final int mark;
  final int point;

 

  activitiesToSend({required this.name , required this.mark , required this.point ,});
  Map<String, dynamic> toJson() => {
    'name': name,
    'mark': mark,
    'point': point,

  };


}




class homeWorkSorah extends Notification {
  final int num;
  final int from;
  final int to;


  homeWorkSorah({required this.num , required this.from , required this.to });
  Map<String, dynamic> toJson() => {
    'num': num,
    'from': from,
    'to': to,

  };


}


class Hadith {
  final int id;
  final int from;
  final int to;
  final int mark;
  final int points;

  const Hadith({required this.id , required this.from , required this.to , required this.mark , required this.points});

  Hadith.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        from = json['from'] as int,
        to = json['to'] as int,
        mark = json['mark'] as int,
        points = json['points'] as int;

  Map<String, dynamic> toJson() => {
    'id': id,
    'from': from,
    'to': to,
    'mark': mark,
    'points': points
  };

}