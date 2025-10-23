

import 'package:flutter/material.dart';
import 'package:masjed/core/utils/snackBarHelper.dart';
import 'package:masjed/core/widgets/DownloadData.dart';
import 'package:masjed/screens/admin_screens/ManagmentScreens/teacherCard.dart';
import 'package:masjed/state/daoraState.dart';
import 'package:masjed/state/profile.dart';
import 'package:provider/provider.dart';

class TeachersScreen extends StatefulWidget {
  const TeachersScreen({super.key});
  @override
  State<TeachersScreen> createState() => _TeachersScreenState();
}

class _TeachersScreenState extends State<TeachersScreen> {
  bool logging =false;

   List<dynamic> DataFromApi = [
  ];
  @override
  Widget build(BuildContext context) {
    
    return Consumer<Profile>(builder: (context, profile, child) {
    return Stack(
          children: [
  
                        
    
    ListView.builder(
      itemCount: DataFromApi.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(top: 30),
          child: teacherCard(
            data: DataFromApi[index],
            updateScreen: downloadData,
          ),
        );
      },
    ),
                       Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Text('تحديث البيانات',style: TextStyle(fontWeight: FontWeight.bold),),
                             DownloaddataBTN(submit:  downloadData, logging: logging, profile: profile),
                             

                            const SizedBox(height: 10,),
                        ],
                          ),
    
          ],
        );
        
        },
        
        );
    
    

  }
  Future<void> downloadData(Profile profile) async {
  if (!mounted) return;
  setState(() {
    logging = true; // التحميل بدأ
  });

  try {
    // جلب daoraId قبل استدعاء الدالة
    final int? daoraId = Provider.of<Daorastate>(context, listen: false).currentDaoraId;
    // استدعاء الدالة وتمرير daoraId
    final List<dynamic> teachers = await profile.get_teachers(daoraId);

    if (!mounted) return;

    setState(() {
      DataFromApi = teachers;
    });
  } catch (e) {
    if (!mounted) return;
    showStyledSnackBar(context, message: e.toString(), isError: true);
    setState(() {
      DataFromApi = [];
    });
  } finally {
    if (mounted) {
      setState(() {
        logging = false; // التحميل انتهى
      });
    }
  }
}
}
