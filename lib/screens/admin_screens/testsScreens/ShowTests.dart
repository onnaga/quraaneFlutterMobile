

import 'package:flutter/material.dart';
import 'package:masjed/core/utils/snackBarHelper.dart';
import 'package:masjed/core/widgets/DownloadData.dart';
import 'package:masjed/models/objects.dart';
import 'package:masjed/screens/admin_screens/testsScreens/TestCard.dart';
import 'package:masjed/state/daoraState.dart';
import 'package:masjed/state/profile.dart';
import 'package:provider/provider.dart';

class Showtests extends StatefulWidget {

  const Showtests({super.key});

  @override
  State<Showtests> createState() => _ShowtestsState();
}

class _ShowtestsState extends State<Showtests> {
  bool logging = false ; 
     List<TestData> DataFromApi = [
  ];
  final firstScrollController = ScrollController();
  

@override
  Widget build(BuildContext context) {
    return Consumer<Profile>(builder: (context, profile, child) {
    return Stack(
          children: [
  
                        
    ListView.builder(
      controller: firstScrollController,
      itemCount: DataFromApi.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(top: 30),
          child: TestCard(
            data: DataFromApi[index],
            methodFromParent:downloadData ,
          ),
        );
      },
    ),
          
                       Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Text(' تحديث البيانات ',style: TextStyle(fontWeight: FontWeight.bold),),
                              
                              DownloaddataBTN(submit: downloadData, logging: logging, profile: profile),
                              
    
                        const SizedBox(height: 10,),
                        ],
                          ),
    
          ],
        );},);
        }

Future<void> downloadData(Profile profile) async {
  setState(() {
    logging = true; // يعني أن التحميل بدأ
  });

  try {
    // جلب daoraId من Provider آخر قبل استدعاء الدالة
    final int daoraId = Provider.of<Daorastate>(context, listen: false).currentDaoraId!;
    
    final List<TestData> fetchedTests = await profile.get_tests(daoraId);

    if (!mounted) return;

    setState(() {
      DataFromApi = fetchedTests;
    });

  } catch (e) {
    if (!mounted) return;
    showStyledSnackBar(context, message: e.toString(), isError: true);
    setState(() {
      DataFromApi = []; // إفراغ البيانات في حالة الخطأ
    });
  } finally {
    // هذا الكود سيعمل دائماً في النهاية
    if (mounted) {
      setState(() {
        logging = false; // يعني أن التحميل انتهى
      });
    }
  }
}

}