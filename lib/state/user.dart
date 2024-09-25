import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:masjed/data/objects.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;

class User extends ChangeNotifier {
  String? baseUrl = "http://10.0.2.2:8000/api/";
  String? token;
  String? username;
  int? id;
  int? privilege;
  UserToShowProfile? profileUserData ;
  List<endedSurah> soarToSend = [];
  List<homeWorkSorah> hSoarToSend = [];
  List<endedSurah> ahadithToSend = [];
  List<homeWorkSorah> hAhadithToSend = [];
  Map<String, dynamic>? details;
  File? image;
  String? image_hash;
  String? teache_name = null;
  final Dio dio = Dio(BaseOptions(headers: {  'content-Type' : 'application/json',
            'Accept' :'application/json'}));
  

  Future<bool> login_via_token(BuildContext context) async {
    print('inside login via token');
    print(token);
    SharedPreferences preferences = await SharedPreferences.getInstance();
    token = preferences.getString('token');
    print(token);
    if (token == "null" || token == null) {
      // // ignore: use_build_context_synchronously
      // Navigator.of(context).popAndPushNamed('login');
      return false;
    }
    // if (!JwtDecoder.isExpired(token as String)) {
    //   preferences.remove('token');

    //   return false;
    // }

    var url = '${baseUrl}get_user_info';
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["authorization"] = "Bearer ${token}";
    var response = await dio.post(url, options: Options(validateStatus: (i) {
      return true;
    }));
            if (response.statusCode == 500) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('يرجى تسجيل الدخول'),
        backgroundColor: const Color.fromARGB(255, 175, 79, 76),
      ));
      return false;
    }
    if (response.statusCode == 401) {
      print(response.data);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(response.data['message']),
        backgroundColor: const Color.fromARGB(255, 175, 79, 76),
      ));
      return false;
    } else {
      this.id = response.data['id'];
      this.username = response.data['name'];
      this.privilege = response.data['privilege'];
      this.details = {
        'phone': response.data['phone_number'],
        'age': response.data['age']
      };
      this.teache_name = response.data['teache_name'];
      this.image_hash = response.data['photo_hash'];
      
      if (image_hash != null) {
        Directory document_directory = await getApplicationDocumentsDirectory();
        File file = new File(
          path.join(
            document_directory.path,
            path.basename(image_hash!),
          ),
        );
        //image exist inside appData
        if (await file.exists()) {
         this.image = file;
        }
         //image not exist inside appData

        
      } else {this.image = null;}

    print("get image");
    

      return true;
    }
  }







  Future<bool> get_user_info(BuildContext context ,int user_id) async {
   

    if (token == "null" || token == null) {
      return false;
    }
    var url = '${baseUrl}get_user_info';
    dio.options.headers['content-Type'] = 'application/json';
            dio.options.headers['Accept'] = 'application/json';

    dio.options.headers["authorization"] = "Bearer ${token}";
        var form_data = FormData.fromMap({
      'id': user_id,
    });
    var response = await dio.post(url,data: form_data ,options: Options(validateStatus: (i) {
      return true;
    }));
            if (response.statusCode == 500) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('مشكلة في جلب بيانات المستخدم'),
        backgroundColor: const Color.fromARGB(255, 175, 79, 76),
      ));
      return false;
    }
    if (response.statusCode == 401) {
      print(response.data);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(response.data['message']),
        backgroundColor: const Color.fromARGB(255, 175, 79, 76),
      ));
      return false;
    } else {
      debugger();
      this.profileUserData=  UserToShowProfile.fromJson(response.data) ;
      
      return true;
    }
  }

  Future<File?> getImage (String id ,image_hash_sended) async {
        make_all_null();
        if (image_hash_sended != null) {
        Directory document_directory = await getApplicationDocumentsDirectory();
        File file = new File(
          path.join(
            document_directory.path,
            path.basename(image_hash_sended!),
          ),
        );
        //image exist inside appData
        if (await file.exists()) {
        this.image = file;
        }
         //image not exist inside appData
        else{
          // getImage(id);
        }
        
      } else {this.image = null;}

    print("get image");
    return this.image;

  }

  Future<bool> login(
      BuildContext context, String username, String password) async {
        
    make_all_null();
    var url = '${baseUrl}login';
    var form_data = FormData.fromMap({
      'name': username,
      'password': password,
    });
debugger();
    var response = await dio.post(url, data: form_data,
        options: Options(validateStatus: (i) {
      return true;
    }));
        if (response.statusCode == 500) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('يرجى تسجيل الدخول'),
        backgroundColor: const Color.fromARGB(255, 175, 79, 76),
      ));
      return false;
    }
    if (response.statusCode == 401) {
      print(response.data);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(response.data['message']),
        backgroundColor: const Color.fromARGB(255, 175, 79, 76),
      ));
      return false;
    } else {
      this.token = response.data['token'];
      Provider.of<SharedPreferences>(context, listen: false)
          .setString('token', this.token as String);
      this.id = response.data['id'];
      this.username = response.data['name'];
      this.privilege = response.data['privilege'];
      this.details = {
        'phone': response.data['phone_number'],
        'age': response.data['age']
      };
      this.teache_name = response.data['teache_name'];
      this.image_hash = response.data['photo_hash'];
      
      if (image_hash != null) {
        Directory document_directory = await getApplicationDocumentsDirectory();
        File file = new File(
          path.join(
            document_directory.path,
            path.basename(image_hash!),
          ),
        );
        //image exist inside appData
        if (await file.exists()) {
        this.image = file;
        print(" image exist");
        }
         //image not exist inside appData
            print(" image image not exist inside appData");
        
      } else {this.image = null;  print("hash image is null");}

    
    

      return true;
    }
  }

  Future<bool> register(BuildContext context, 
  // File image,
   String username,
      String password, String phone, int age, List<int> chapters) async {
        debugger();
      make_all_null();
    var url = '${baseUrl}register';
    // this.image_hash = md5.convert(utf8.encode('${image.path}$username')).toString();
    var form_data = FormData.fromMap({
      'name': username,
      'password': password,
      'phone_number': phone,
      'age': age.toString(),
      'ended_quraan_in_aukaf': chapters.toString(),
      // 'photo': MultipartFile.fromBytes(image.readAsBytesSync(),
      //     filename: image.path),
      // 'photo_hash': this.image_hash
    });

    var response = await dio.post(url, data: form_data,
        options: Options(validateStatus: (i) {
      return true;
    }));

    if (response.statusCode == 500) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('حساب المستخدم تم تسجيله مسبقا قم بتسجيل الدخول'),
        backgroundColor: const Color.fromARGB(255, 175, 79, 76),
      ));
      return false;
    }
    if (response.statusCode == 403) {
      print(response.data);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(response.data['messages']),
        backgroundColor: const Color.fromARGB(255, 175, 79, 76),
      ));
      return false;
    } else {
      this.token = response.data['token'];
      Provider.of<SharedPreferences>(context, listen: false)
          .setString('token', this.token as String);
          this.id = response.data['id'];
      this.username = response.data['name'];
      this.privilege = response.data['privilege'];
      this.details = {
        'phone': response.data['phone_number'],
        'age': response.data['age']
      };
      this.image = image;
      this.image_hash = image_hash;
      // Directory document_directory = await getApplicationDocumentsDirectory();
      // File file = new File(
      //   path.join(
      //     document_directory.path,
      //     ("${image_hash!}"),
      //   ),
      // );
      // await file.writeAsBytes(image.readAsBytesSync());
      // showDialog(
      //   context: context,
      //   builder: (BuildContext content) => AlertDialog(
      //     title: Text('image saved succefully'),
      //     content: Image.file(file),
      //   ),
      // );
      
      return true;
    }
  }


  Future<bool> resetPassword(
      BuildContext context, String oldPassword, String newPassword) async {
    debugger();
    var url = '${baseUrl}update_password_user';
    var form_data = FormData.fromMap({
      'old_password': oldPassword,
      'password': newPassword,
    });
    dio.options.headers['content-Type'] = 'application/json';
            dio.options.headers['Accept'] = 'application/json';

    dio.options.headers["authorization"] = "Bearer ${token}";
    var response = await dio.post(url, data: form_data,
        options: Options(validateStatus: (i) {
      return true;
    }));
        if (response.statusCode == 500) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('مشكلة في الخادم'),
        backgroundColor: const Color.fromARGB(255, 175, 79, 76),
      ));
      return false;
    }
    if (response.statusCode == 401) {
      print(response.data);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(response.data['message']),
        backgroundColor: const Color.fromARGB(255, 175, 79, 76),
      ));
      return false;
    } else {
      debugger();
      this.token = response.data['token'];
      Provider.of<SharedPreferences>(context, listen: false).remove('token');
      Provider.of<SharedPreferences>(context, listen: false)
          .setString('token', this.token as String);
      return true;
    }
  }


  Future<bool> update_details(
      BuildContext context, int age, String phone_number ) async {
    debugger();
    var url = '${baseUrl}update_details';
    var form_data = FormData.fromMap({
      'age': age,
      'phone_number': phone_number,
    });
    dio.options.headers['content-Type'] = 'application/json';
            dio.options.headers['Accept'] = 'application/json';

    dio.options.headers["authorization"] = "Bearer ${token}";
    var response = await dio.post(url, data: form_data,
        options: Options(validateStatus: (i) {
      return true;
    }));
        if (response.statusCode == 500) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('مشكلة في الخادم'),
        backgroundColor: const Color.fromARGB(255, 175, 79, 76),
      ));
      return false;
    }
    if (response.statusCode == 401) {
      print(response.data);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(response.data['message']),
        backgroundColor: const Color.fromARGB(255, 175, 79, 76),
      ));
      return false;
    } else {
      debugger();

      this.details = {
        'phone': phone_number,
        'age': age
      };
      return true;
    }
  }


  Future<bool> add_admin(
      BuildContext context, String username, String password,String privilege) async {
   debugger();

    var url = '${baseUrl}add_admin';
    var form_data = FormData.fromMap({
      'name': username,
      'password': password,
      'privilege':privilege
    });
        dio.options.headers['content-Type'] = 'application/json';
            dio.options.headers['Accept'] = 'application/json';

    dio.options.headers["authorization"] = "Bearer ${token}";
    var response = await dio.post(url, data: form_data,
        options: Options(validateStatus: (i) {
      return true;
    }));
        if (response.statusCode == 500) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('حساب المستخدم تم تسجيله مسبقاقم بتغيير الاسم'),
        backgroundColor: const Color.fromARGB(255, 175, 79, 76),
      ));
      return false;
    }
    if (response.statusCode == 401) {
      print(response.data);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(response.data['message']),
        backgroundColor: const Color.fromARGB(255, 175, 79, 76),
      ));
      return false;
    } else {
      debugger();
      print('user_added');
    

      return true;
    }
  }




  Future<bool> add_latest_quraan_hadith(
      BuildContext context, int  userId, List<dynamic> dataToSend ,bool quran) async {
debugger();
    dio.options.headers["authorization"] = "Bearer ${token}";
    var url='';
    if(quran){
     url = '${baseUrl}add_latest_quraan/$userId';

    }
    else{
           url = '${baseUrl}add_latest_hadith/$userId';

    }

    var response = await dio.post(url, data:jsonEncode(dataToSend) ,
        options: Options(validateStatus: (i) {
      return true;
    }));
        if (response.statusCode == 500) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('مشكلة في الخادم'),
        backgroundColor: const Color.fromARGB(255, 175, 79, 76),
      ));
      return false;
    }
    if (response.statusCode == 401) {
      print(response.data);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(response.data['message']),
        backgroundColor: const Color.fromARGB(255, 175, 79, 76),
      ));
      return false;
    } else {
      debugger();
      print('user_added');
    

      return true;
    }
  }



  Future<bool> add_latest_activity(
      BuildContext context, int  userId, List<dynamic> dataToSend ) async {
debugger();
    dio.options.headers["authorization"] = "Bearer ${token}";

    var url = '${baseUrl}add_latest_activity/$userId';


    var response = await dio.post(url, data:jsonEncode(dataToSend) ,
        options: Options(validateStatus: (i) {
      return true;
    }));
        if (response.statusCode == 500) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('مشكلة في الخادم'),
        backgroundColor: const Color.fromARGB(255, 175, 79, 76),
      ));
      return false;
    }
    if (response.statusCode == 401) {
      print(response.data);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(response.data['message']),
        backgroundColor: const Color.fromARGB(255, 175, 79, 76),
      ));
      return false;
    } else {
      debugger();
      print('user_added');
    

      return true;
    }
  }





  Future<bool> add_latest_notes(
      BuildContext context, int  userId, String note , String lostPoint ) async {
debugger();
    dio.options.headers["authorization"] = "Bearer ${token}";

    var url = '${baseUrl}add_latest_note/$userId';


     var form_data = FormData.fromMap({
      'lost_point':lostPoint ,
      'note':note
    });

    var response = await dio.post(url, data:form_data ,
        options: Options(validateStatus: (i) {
      return true;
    }));
        if (response.statusCode == 500) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('مشكلة في الخادم'),
        backgroundColor: const Color.fromARGB(255, 175, 79, 76),
      ));
      return false;
    }
    if (response.statusCode == 401) {
      print(response.data);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(response.data['message']),
        backgroundColor: const Color.fromARGB(255, 175, 79, 76),
      ));
      return false;
    } else {
      debugger();
      print('user_added');
    

      return true;
    }
  }










  Future<bool> Delete_user(
      BuildContext context ,user_id) async {
   debugger();

    var url = '${baseUrl}users?$user_id';
 
    var response = await dio.delete(url,
        options: Options(validateStatus: (i) {
      return true;
    }));
        if (response.statusCode == 500) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('توجد مشكلة في الخادم'),
        backgroundColor: const Color.fromARGB(255, 175, 79, 76),
      ));
      return false;
    }
    if (response.statusCode == 401) {
      print(response.data);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(response.data['message']),
        backgroundColor: const Color.fromARGB(255, 175, 79, 76),
      ));
      return false;
    } else {
      debugger();

      print('user_deleted');
    

      return true;
    }
  }


  Future<bool> leave_student(
      BuildContext context ,user_id) async {
   debugger();

    var url = '${baseUrl}leave_student?user_id=$user_id';
 
    var response = await dio.get(url,
        options: Options(validateStatus: (i) {
      return true;
    }));
        if (response.statusCode == 500) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('توجد مشكلة في الخادم'),
        backgroundColor: const Color.fromARGB(255, 175, 79, 76),
      ));
      return false;
    }
    if (response.statusCode == 401) {
      print(response.data);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(response.data['message']),
        backgroundColor: const Color.fromARGB(255, 175, 79, 76),
      ));
      return false;
    } else {
      debugger();

      print('user_leaved');
    

      return true;
    }
  }




  void update_image(File image) {
    this.image = image;
    notifyListeners();
  }
  void make_all_null(){
    this.details = null ;
    this.image = null;
  this.username = null;
  this.teache_name = null;
  this.image_hash = null;
  this.privilege = null;
  this.token = null;
  }

}
