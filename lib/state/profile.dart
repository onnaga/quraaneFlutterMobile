import 'dart:convert';
import 'dart:developer';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:masjed/data/objects.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends ChangeNotifier {
  String? baseUrl = "http://10.0.2.2:8000/api/";
  int? m_days;
  int  q_points =0;
  int  h_points=0;
  int  a_points=0;
  int  l_points=0;
  
  reciveLatest?recivelatest;
  List<dynamic>?ReportsList;
  List<dynamic>?StudetntsWithoutTeachers;
  List<dynamic>?TeachersList;
  List<OneUserRank>?RankUsers;
  List<TestData>?TestsList;
  List<TestUserAccepters> TestUseraccepters=[];
  List<TestUserAccepters> success_users =[];
  List<TestUserAccepters> fail_users =[];
  List<dynamic>? ended_parts;
  List<User_Notification>? notifications;
  final Dio dio = Dio();

  get_m_days() async {
    if (m_days != null) {
      return m_days;
    }
  }


  Future<bool> get_score(
    
      BuildContext context, int privilege, int user_id) async {
    debugger();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    if (token == "null" || token == null) {
      return false;
    }
    dio.options.headers['content-Type'] = 'application/json';
        dio.options.headers['Accept'] = 'application/json';

    dio.options.headers["authorization"] = "Bearer ${token}";
    if (privilege == 2 || privilege == 3) {
      
      var url = '${baseUrl}get_score';
      var form_data = FormData.fromMap({
        'id': user_id,
      });
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
            if(response.data['points']!=null){
                          this.q_points=response.data['points']['q_points'] ?? 0;
            this.h_points=response.data['points']['h_points'] ?? 0;
            this.a_points=response.data['points']['a_points'] ?? 0;
            this.l_points=response.data['points']['l_points'] ?? 0;
            this.ended_parts = jsonDecode(response.data['ended_quraan_in_aukaf']);
            }
            else{
            this.q_points= 0;
            this.h_points= 0;
            this.a_points= 0;
            this.l_points= 0;
            this.ended_parts = jsonDecode(response.data['ended_quraan_in_aukaf']);
            }

      }

      print("get score");

      return true;
    } else {
      var url = '${baseUrl}get_score';

      var response = await dio.post(url, options: Options(validateStatus: (i) {
        return true;
      }));
      debugger();

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
        if(response.data['points'] == null ){
                      this.q_points= 0;
            this.h_points= 0;
            this.a_points= 0;
            this.l_points= 0;
              this.ended_parts = jsonDecode(response.data['ended_quraan_in_aukaf']);
              return true;
        }
            this.q_points=response.data['points']['q_points'] ?? 0;
            this.h_points=response.data['points']['h_points'] ?? 0;
            this.a_points=response.data['points']['a_points'] ?? 0;
            this.l_points=response.data['points']['l_points'] ?? 0;
        this.ended_parts = jsonDecode(response.data['ended_quraan_in_aukaf']);
      }

      print("get score");
    }

    return true;
  }


  Future<bool> get_Latest(
      BuildContext context, int privilege, int user_id) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');
    debugger();
    if (token == "null" || token == null) {
      return false;
    }
    dio.options.headers['content-Type'] = 'application/json';
        dio.options.headers['Accept'] = 'application/json';

    dio.options.headers["authorization"] = "Bearer ${token}";
    if (privilege == 2 || privilege == 3) {
      var url = '${baseUrl}get_latest_for_student?user_id=$user_id';
      var response = await dio.get(url,
          options: Options(validateStatus: (i) {
        return true;
      }));
      debugger();
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
            if(response.data.isEmpty){
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("تمت عملية جلب البانات"),
          backgroundColor: Color.fromARGB(255, 76, 175, 78),
        ));
              debugger();
               this.recivelatest =null;
               return true;
            }
            debugger();
            this.recivelatest =reciveLatest.fromJson(response.data[0]);
            debugger();
            print(this.recivelatest);
      }

      print("get latest");

      return true;
    } else {
      var url = '${baseUrl}get_latest_for_student';

      var response = await dio.get(url, options: Options(validateStatus: (i) {
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
        if(response.data.isEmpty){
           this.recivelatest= null ;
           return true;
        }
            this.recivelatest =reciveLatest.fromJson(response.data[0]);
            print(this.recivelatest);
      }

      print("get latest");
    }

    return true;
  }

 



  Future<bool> get_rank(
    
      BuildContext context ,bool global) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    if (token == "null" || token == null) {
      return false;
    }
    dio.options.headers['content-Type'] = 'application/json';
        dio.options.headers['Accept'] = 'application/json';

    dio.options.headers["authorization"] = "Bearer ${token}";
    
    print(token);
      var url = global? '${baseUrl}get_rank_masjed' : '${baseUrl}get_rank_my_group';
      var response = await dio.get(url,
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
        this.RankUsers=[];
            response.data.forEach((item) => {
            this.RankUsers!.add(OneUserRank.fromJson(item)),
            });
            print(this.RankUsers);

            RankUsers!.sort((a, b) => b.points.compareTo(a.points));
            
      }

      print("get Rank");

      return true;
    

    
  }





  Future<bool> add_wanting_students(
    
    
      BuildContext context ,List<int> watingStudents) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');
debugger();
    if (token == "null" || token == null) {
      return false;
    }
    dio.options.headers['content-Type'] = 'application/json';
        dio.options.headers['Accept'] = 'application/json';

    dio.options.headers["authorization"] = "Bearer ${token}";
    
    print(token);
      var url = '${baseUrl}add_wanting_students';
      var response = await dio.post(url,data: jsonEncode(watingStudents),
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
      }
debugger();
      print("add wanting students");

      return true;
    

    
  }




  Future<bool> get_tests(
    
      BuildContext context ) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    if (token == "null" || token == null) {
      return false;
    }
    dio.options.headers['content-Type'] = 'application/json';
        dio.options.headers['Accept'] = 'application/json';

    dio.options.headers["authorization"] = "Bearer ${token}";
    
      var url = '${baseUrl}show_tests' ;
      
      var response = await dio.get(url,
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
  
        this.TestsList=[];
            response.data.forEach((item) => {
            this.TestsList!.add(TestData.fromJson(item)),
            });
            print(this.TestsList);            
      }

      print("get tests");

      return true;
    

    
  }


  Future<bool> show_test_accepters(
      BuildContext context ,int test_id) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    if (token == "null" || token == null) {
      return false;
    }
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["authorization"] = "Bearer ${token}";
    
      var url = '${baseUrl}show_test_accepters/$test_id';
      var response = await dio.get(url,
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
 this.TestUseraccepters=[];
            response.data.forEach((item) => {
            this.TestUseraccepters.add(TestUserAccepters.fromJson(item)),
            });
            print(this.TestUseraccepters);
            
      }

      print("get Accepted users");

      return true;
    

    
  }


  Future<bool> update_test_accepter_data(
      BuildContext context ,int test_id,int user_id , List<int> the_part_to_test_in,String rating,String notes) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    if (token == "null" || token == null) {
      return false;
    }
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["authorization"] = "Bearer ${token}";
    
      var url = '${baseUrl}update_test_accepter_data/$test_id/$user_id';
       var form_data = FormData.fromMap({
      'the_part_to_test_in': the_part_to_test_in.toString(),
      'rating':rating.toString(),
      'notes': notes,
    });
      var response = await dio.post(url,data:form_data ,
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
      } 
      try {
            if (response.data.substring(0,30) == 'SQLSTATE[22007]: Invalid datetime format: 1366 Incorrect integer value: '.substring(0,30)) {
        print(response.data);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("أدخل رقما من 1 إلى 100 في خانة التقييم"),
          backgroundColor: const Color.fromARGB(255, 175, 79, 76),
        ));
        return false;
      } 
      } catch (e) {
        //if response data is not string it will throw exception there we catch it
            
            print(response.data);
            
      }

      

      

      print("update data to Accepter test");

      return true;
    

    
  }


  Future<bool> show_success_students_in_test(
      BuildContext context ,int test_id) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    if (token == "null" || token == null) {
      return false;
    }
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["authorization"] = "Bearer ${token}";
    
      var url = '${baseUrl}show_success_students_in_test/$test_id';
      var response = await dio.get(url,
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
 this.success_users=[];
 this.fail_users=[];
            response.data['success_users'].forEach((item) => {
            this.success_users.add(TestUserAccepters.fromJson(item)),
            });
            print(this.success_users);
            response.data['fail_users'].forEach((item) => {
            this.fail_users.add(TestUserAccepters.fromJson(item)),
            });
             print(this.fail_users);
            
      }

      print("get Success fail users");

      return true;
    

    
  }



  Future<bool> take_student(
      BuildContext context ,int userId) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    if (token == "null" || token == null) {
      return false;
    }
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["authorization"] = "Bearer ${token}";
    
      var url = '${baseUrl}take_student?user_id=$userId';
      var response = await dio.get(url,
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
      } 

      print("get Success fail users");

      return true;
    

    
  }



  Future<bool> delete_test(
      BuildContext context ,int test_id) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    if (token == "null" || token == null) {
      return false;
    }
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["authorization"] = "Bearer ${token}";
    
      var url = '${baseUrl}delete_test/$test_id';
      var response = await dio.delete(url,
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
      }
      
      print("delete test ");

      return true;
    

    
  }

  Future<bool> make_aukaf_test_for_success_students(
      BuildContext context ,int test_id ,String at , String notes) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');
debugger();
    if (token == "null" || token == null) {
      return false;
    }
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["authorization"] = "Bearer ${token}";
    
      var url = '${baseUrl}make_aukaf_test_for_success_students/$test_id';
          var form_data = FormData.fromMap({
      'at': at,
      'notes': notes,
    });
      var response = await dio.post(url,data: form_data,
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
      }
      
      print("add aukaf test");

      return true;
    

    
  }


  Future<bool> add_new_test(
      BuildContext context ,String at , String notes) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');
    if (token == "null" || token == null) {
      return false;
    }
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["authorization"] = "Bearer ${token}";
    
      var url = '${baseUrl}add_new_test';
          var form_data = FormData.fromMap({
      'at': at,
      'notes': notes,
    });
      var response = await dio.post(url,data: form_data,
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
      }
      
      print("add  test");

      return true;
    

    
  }





  Future<bool> accept_test(
    
      BuildContext context ,int test_id) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    if (token == "null" || token == null) {
      return false;
    }
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["authorization"] = "Bearer ${token}";
    
      var url = '${baseUrl}accept_test/$test_id';
      var response = await dio.get(url,
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
      }
      
      print("accept test ");

      return true;
    

    
  }






  Future<bool> delete_accepted_test(
      BuildContext context ,int test_id) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    if (token == "null" || token == null) {
      return false;
    }
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["authorization"] = "Bearer ${token}";
    
      var url = '${baseUrl}delete_accepted_test/$test_id';

      var response = await dio.delete(url,
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
      }
      
      print("delete_accepted_test ");

      return true;
    

    
  }


  Future<bool> show_reports(
      BuildContext context ) async {
        
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    if (token == "null" || token == null) {
      return false;
    }
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["authorization"] = "Bearer ${token}";
    
      var url = '${baseUrl}show_reports';
      debugger();
      var response = await dio.get(url,
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
      }
      this.ReportsList =response.data;

      return true;
  }


  
  Future<bool> show_users_without_teacher(
      BuildContext context ) async {
        
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    if (token == "null" || token == null) {
      return false;
    }
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["authorization"] = "Bearer ${token}";
    
      var url = '${baseUrl}show_users_without_teacher';
      var response = await dio.get(url,
          options: Options(validateStatus: (i) {
        return true;
      }));
debugger();
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
      }
      this.StudetntsWithoutTeachers =response.data;

      return true;
  }




  Future<bool> get_teachers(
      BuildContext context ) async {
        debugger();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');

    if (token == "null" || token == null) {
      return false;
    }
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers['Accept'] = 'application/json';
    dio.options.headers["authorization"] = "Bearer ${token}";
    
      var url = '${baseUrl}show_all_users';
      var response = await dio.post(url,data: {},
          options: Options(validateStatus: (i) {
        return true;
      }),);
      
      debugger();
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
      }
      this.TeachersList =response.data;

      return true;
  }



  get_ended_parts() async {
    if (ended_parts == null) {
      return ended_parts;
    }
  }

  get_notifications() async {
    if (notifications == null) {
      return notifications;
    }
  }
}
