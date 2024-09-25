import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:masjed/core/utils/QuraansoarManage.dart';
import 'package:masjed/core/utils/sizeConfig.dart';
import 'package:masjed/core/widgets/DownloaddataContextBTN.dart';
import 'package:masjed/state/profile.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';

class UserLatest extends StatefulWidget {
  int userId= 0;
  UserLatest();
  UserLatest.forteacher({required this.userId});
  @override
  State<UserLatest> createState() => _UserLatestState();
}

class _UserLatestState extends State<UserLatest> {
  bool logging = true ; 
  @override
  Widget build(BuildContext context) {
    return Consumer<Profile>(builder: (context, profile, child) {
      return SingleChildScrollView(
          child: Column(
        children: [
          SizedBox(height: 20),
          Text(
            'لمتابعة الإنجازات السابقة توجه الى صفحة التقارير',
            style: TextStyle(
                fontSize: sizeConfig.defaultSize! * 2,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                const Text(
                  'تحميل أحدث البيانات',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                DownloaddataContextBTN(submit: DownloadData, logging: logging, profile: profile, sendedcontext: context),
           
              ],
            ),
          ),
          SizedBox(height: 20),
          QuranWidget(
          quran: profile.recivelatest==null?[] : profile.recivelatest!.quran,
          quranHomework:  profile.recivelatest==null?[] :profile.recivelatest!.quranHomework,
          CreatedAt:profile.recivelatest==null?'' :profile.recivelatest!.createdAt! ,
          ),
          SizedBox(height: 30),
          HadithWidget(
          hadith: profile.recivelatest==null?[] : profile.recivelatest!.hadith,
          hadithHomework:  profile.recivelatest==null?[] :profile.recivelatest!.hadithHomework,
          CreatedAt:profile.recivelatest==null?'' :profile.recivelatest!.createdAt! ,
          ),
          SizedBox(height: 30),
          ActivityWidget(
            activities: profile.recivelatest==null?[] : profile.recivelatest!.activities,
            CreatedAt:profile.recivelatest==null?'' :profile.recivelatest!.createdAt! ,

          ),
          SizedBox(height: 30),
          NotesWidget(
            note:profile.recivelatest==null?'' :profile.recivelatest!.note! ,
            LPoints:profile.recivelatest==null?'' :profile.recivelatest!.LPoints!  ,
            CreatedAt:profile.recivelatest==null?'' :profile.recivelatest!.createdAt! ,

          )
        ],
      ));
    });
  }

  Future<void> DownloadData(BuildContext context, Profile profile) async {
    {          

                        setState(() {
                          logging = false ; 
                        });
                       int privilege =
                       
                           Provider.of<User>(context, listen: false).privilege!;
    
                       await profile.get_Latest(context, privilege, widget.userId).then((data){
                        logging = true ;
setState(() {});

                       });
                       ;
                     }
  }
}

class QuranWidget extends StatelessWidget {
  final List<dynamic>?quran;
  final List<dynamic>? quranHomework;
  final String CreatedAt ;
  const QuranWidget({required this.quran, required this.quranHomework ,required this.CreatedAt});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Container(
            decoration: BoxDecoration(
                color: Colors.lightGreen[400],
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15))),
            height: sizeConfig.defaultSize! * 3,
            width: sizeConfig.defaultSize! * 13,
            child: const Center(
              child: Text(
                'تسميع القرآن',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            ),
          ),
        ),
        Card(
          shadowColor: Colors.black,
          color: Colors.lightGreen[400],
          elevation: 3,
          margin: EdgeInsets.symmetric(horizontal: sizeConfig.defaultSize! * 1),
          shape: OutlineInputBorder(
              borderSide:
                  BorderSide(width: 0, color: Colors.lightGreen[400] as Color),
              borderRadius: BorderRadius.all(Radius.circular(15))),
          child: Column(
            children: [
              const SizedBox(
                height: 5,
              ),
              Center(
                child: SizedBox(
                  width: sizeConfig.defaultSize! * 14,
                  height: sizeConfig.defaultSize! * 14,
                  child: Image.asset('images/quran_book.png'),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'آخر تسميع : ',
                style: TextStyle(fontSize: sizeConfig.defaultSize! * 2),
              ),
              ...List<Widget>.generate(quran!.length, (i) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
                  child: Material(
                      color: Colors.lightGreen[300],
                      borderRadius: BorderRadius.circular(50),
                      child:  Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          children: [
                                                      const SizedBox(height: 5,),

                            Row(
                              children: [
                                const Expanded(
                                    flex: 3,
                                    child: Icon(Icons.bookmark_outline_sharp,
                                        color: Colors.black45)),
                                Expanded(
                                    flex: 17,
                                    child: Text(
                                    
                                      'سورة ${Quraansoarmanage.soarList[quran![i]['num']]} من الاية ${quran![i]['from']} الى ${quran![i]['to']}',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.black54),
                                    )),
                                Expanded(flex: 10, child: Grade(((quran![i]['mark']*5)/100).round())),
                              ],
                            ),
                          const SizedBox(height: 5,),
                          Text("النقاط المكتسبة: ${quran![i]['point']}"),
                          ],
                        ),
                      )),
                );
              }),
              const SizedBox(height: 20),
              Text(
                'آخر واجب : ',
                style: TextStyle(fontSize: sizeConfig.defaultSize! * 2),
              ),
              ...List<Widget>.generate(quranHomework!.length, (i) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
                  child: Material(
                      color: Colors.lightGreen[300],
                      borderRadius: BorderRadius.circular(50),
                      child:  Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Expanded(
                                flex: 3,
                                child: Icon(Icons.bookmark_outline_sharp,
                                    color: Colors.black45)),
                            Expanded(
                              flex: 17,
                              child: Text(
'سورة ${Quraansoarmanage.soarList[quranHomework![i]['num']]} من الاية ${quranHomework![i]['from']} الى ${quranHomework![i]['to']}',
                                style:const TextStyle(
                                    fontSize: 16, color: Colors.black54),
                              ),
                            ),
                          ],
                        ),
                      )),
                );
              }),
              ListTile(
                leading: const Icon(Icons.access_time_outlined),
                title: const Text('تاريخ الإضافة :'),
                trailing: Text(
                  CreatedAt!=''? '  ${CreatedAt.split('T')[0]}  عند الساعة : ${CreatedAt.split('T')[1].split(":")[0]}':'البيانات غير محدثة',
                  style: const TextStyle(fontSize: 16),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class HadithWidget extends StatelessWidget {
    final List<dynamic>?hadith;
  final List<dynamic>? hadithHomework;
  final String CreatedAt ;

  const HadithWidget({required this.hadith , required this.hadithHomework , required this.CreatedAt});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Container(
            decoration: BoxDecoration(
                color: Colors.lightGreen[400],
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15))),
            height: sizeConfig.defaultSize! * 3,
            width: sizeConfig.defaultSize! * 13,
            child: const Center(
              child: Text(
                'تسميع الحديث',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            ),
          ),
        ),
        Card(
            shadowColor: Colors.black,
            color: Colors.lightGreen[400],
            elevation: 3,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            shape: OutlineInputBorder(
                borderSide: BorderSide(
                    width: 0, color: Colors.lightGreen[400] as Color),
                borderRadius: BorderRadius.all(Radius.circular(15))),
            child: Column(
              children: [
                SizedBox(
                  height: 5,
                ),
                Center(
                  child: SizedBox(
                    width: sizeConfig.defaultSize! * 14,
                    height: sizeConfig.defaultSize! * 14,
                    child: Image.asset('images/hadith_book.png'),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'آخر تسميع : ',
                  style: TextStyle(fontSize: sizeConfig.defaultSize! * 2),
                ),
                ...List<Widget>.generate(hadith!.length, (i) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3, vertical: 8),
                    child: Material(
                        color: Colors.lightGreen[300],
                        borderRadius: BorderRadius.circular(50),
                        child:  Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Column(
                            children: [
                                const SizedBox(height: 5,),
                          
                              Row(
                                children: [
                                  Expanded(
                                      flex: 3,
                                      child: Icon(Icons.book_outlined,
                                          color: Colors.black45)),
                                  Expanded(
                                      flex: 17,
                                      child: Text(
                                        'الرقم:${hadith![i]['num']} من السطر ${hadith![i]['from']} الى ${hadith![i]['to']}',
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.black54),
                                      )),
                                  Expanded(flex: 10, child: Grade(((hadith![i]['mark']*5)/100).round())),
                                ],
                              ),
                              const SizedBox(height: 5,),
                          Text("النقاط المكتسبة: ${hadith![i]['point']}"),
                            
                            ],
                          ),
                        )),
                  );
                }),
                SizedBox(height: 20),
                Text(
                  'آخر واجب : ',
                  style: TextStyle(fontSize: sizeConfig.defaultSize! * 2),
                ),
                ...List<Widget>.generate(hadithHomework!.length, (i) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3, vertical: 8),
                    child: Material(
                        color: Colors.lightGreen[300],
                        borderRadius: BorderRadius.circular(50),
                        child:  Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 3,
                                  child: Icon(Icons.book_outlined,
                                      color: Colors.black45)),
                              Expanded(
                                  flex: 17,
                                  child: Text(
                                    'الرقم:${hadithHomework![i]['num']} من السطر ${hadithHomework![i]['from']} الى ${hadithHomework![i]['to']}',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.black54),
                                  )),
                            ],
                          ),
                        )),
                  );
                }),
                SizedBox(height: 5),
                ListTile(
                  leading: Icon(Icons.access_time_outlined),
                  title: Text('التاريخ'),
                  trailing: Text(
                  CreatedAt!=''? '  ${CreatedAt.split('T')[0]}  عند الساعة : ${CreatedAt.split('T')[1].split(":")[0]}':'البيانات غير محدثة',
                      style: TextStyle(fontSize: 16)),
                )
              ],
            ))
      ],
    );
  }
}

class ActivityWidget extends StatelessWidget {
    final List<dynamic>?activities;
    final String  CreatedAt;

  const ActivityWidget({required this.activities ,required this.CreatedAt});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Container(
            decoration: BoxDecoration(
                color: Colors.lightGreen[400],
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15))),
            height: sizeConfig.defaultSize! * 3,
            width: sizeConfig.defaultSize! * 13,
            child: Center(
              child: Text(
                'أنشطة',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            ),
          ),
        ),
        SingleChildScrollView(
          child: Card(
              shadowColor: Colors.black,
              color: Colors.lightGreen[400],
              elevation: 3,
              margin: EdgeInsets.symmetric(horizontal: 10),
              shape: OutlineInputBorder(
                  borderSide: BorderSide(
                      width: 0, color: Colors.lightGreen[400] as Color),
                  borderRadius: BorderRadius.all(Radius.circular(15))),
              child: Column(
                children: [
                  SizedBox(
                    height: 5,
                  ),
                  Center(
                    child: SizedBox(
                      width: sizeConfig.defaultSize! * 14,
                      height: sizeConfig.defaultSize! * 14,
                      child: Image.asset('images/checklist.png'),
                    ),
                  ),
                  SizedBox(height: 20),
                  ...List<Widget>.generate(activities!.length, (i) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3, vertical: 8),
                      child: Material(
                          color: Colors.lightGreen[300],
                          borderRadius: BorderRadius.circular(50),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Column(
                              children: [
                                  const SizedBox(height: 5,),
                           
                                Row(
                                  children: [
                                    Expanded(
                                        flex: 3,
                                        child: Icon(Icons.sticky_note_2_outlined,
                                            color: Colors.black45)),
                                    Expanded(
                                        flex: 17,
                                        child: Text(
                                          'اسم النشاط: ${activities![i]['name']}',
                                          style: TextStyle(
                                              fontSize: 16, color: Colors.black54),
                                        )),
                                        Expanded(flex: 10, child: Grade(((activities![i]['mark']*5)/100).round()))
                                  ],
                                ),
                                const SizedBox(height: 5,),
                            Text("النقاط المكتسبة: ${activities![i]['point']}"),
                              
                              ],
                            ),
                          )),
                    );
                  }),
                  SizedBox(height: 5),
                  ListTile(
                    leading: Icon(Icons.access_time_outlined),
                    title: Text('التاريخ'),
                    trailing: Text(
                    CreatedAt!=''? '  ${CreatedAt.split('T')[0]}  عند الساعة : ${CreatedAt.split('T')[1].split(":")[0]}':'البيانات غير محدثة',
                        style: TextStyle(fontSize: 16)),
                  )
                ],
              )),
        )
      ],
    );
  }
}

class NotesWidget extends StatelessWidget {
  final String note ;
  final String LPoints;
  final String CreatedAt;

  const NotesWidget({required this.note ,required this.LPoints, required this.CreatedAt});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Container(
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 204, 111, 101),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15))),
            height: sizeConfig.defaultSize! * 3,
            width: sizeConfig.defaultSize! * 13,
            child: Center(
              child: Text(
                'الملاحظات',
                style: TextStyle(
                    fontSize: 18, color: Color.fromARGB(255, 255, 255, 255)),
              ),
            ),
          ),
        ),
        Card(
            shadowColor: Colors.black,
            color: Colors.lightGreen[400],
            elevation: 3,
            margin: EdgeInsets.symmetric(horizontal: 10),
            shape: OutlineInputBorder(
                borderSide: BorderSide(
                    width: 0, color: Colors.lightGreen[400] as Color),
                borderRadius: BorderRadius.all(Radius.circular(15))),
            child: Column(
              children: [
                SizedBox(
                  height: 5,
                ),
                Center(
                  child: SizedBox(
                    width: sizeConfig.defaultSize! * 10,
                    height: sizeConfig.defaultSize! * 10,
                    child: Image.asset(
                      'images/penalty.png',
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3, vertical: 8),
                    child: Material(
                        color: const Color.fromARGB(255, 213, 129, 129),
                        borderRadius: BorderRadius.circular(50),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 3,
                                  child: Icon(Icons.sticky_note_2_outlined,
                                      color: Colors.black45)),
                              Expanded(
                                  flex: 17,
                                  child: Text(
                                    '$note',
                                    style: TextStyle(
                                        fontSize: 16, color: Color.fromARGB(255, 255, 255, 255)),
                                  )),
                            ],
                          ),
                        )),
                  ),
                 SizedBox(height: 15),
                           Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3, vertical: 8),
                    child: Material(
                        color: const Color.fromARGB(255, 213, 129, 129),
                        borderRadius: BorderRadius.circular(50),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Container(
                            width:  250,
                            child: Row(
                              children: [
                                    SizedBox(width: 10,),
                                    Icon(Icons.do_not_disturb_alt_outlined,
                                        color: Colors.black45),
                                        SizedBox(width: 10,),
                                Text(
                                  'النقاط المخصومة : $LPoints',
                                  style: TextStyle(
                                      fontSize: 16, color: Color.fromARGB(255, 255, 255, 255)),
                                ),
                              ],
                            ),
                          ),
                        )),
                  ),
                 
              
                              ListTile(
                  leading: Icon(Icons.access_time_outlined),
                  title: Text('التاريخ'),
                  trailing: Text(
                  CreatedAt!=''? '  ${CreatedAt.split('T')[0]}  عند الساعة : ${CreatedAt.split('T')[1].split(":")[0]}':'البيانات غير محدثة',
                      style: TextStyle(fontSize: 16)),
                )
              ],
            ))
      ],
    );
  }
}

class Grade extends StatelessWidget {
  final int grade;

  const Grade(this.grade);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List<Widget>.generate(5, (i) {
            return Icon((grade > i) ? Icons.star : Icons.star_outline,
                color: (grade > i) ? Colors.yellow[700] : Colors.black45);
          }),
        ),
        Center(
          child: Text(
            grade_to_text[grade],
            style: TextStyle(fontSize: 15, color: Colors.black45),
          ),
        )
      ],
    );
  }

  static const List<String> grade_to_text = [
    'سيئ',
    'ضعيف',
    'وسط',
    'جيد',
    'جيد جدا',
    'ممتاز'
  ];
}
