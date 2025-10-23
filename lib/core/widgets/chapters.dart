import 'package:flutter/material.dart';
import 'package:masjed/core/utils/QuraansoarManage.dart';

class Chapters extends StatefulWidget {
   final List<int>? initialSelected;
  const Chapters({super.key ,required this.initialSelected});

  @override
  State<StatefulWidget> createState() => ChaptersState();
}

class ChaptersState extends State<Chapters> {
late List<Map<String, dynamic>> list;
  @override
  void initState() {
    super.initState();
    list = List.generate(30, (i) {
      return {
        'name': juz_list[i],
        'checked': widget.initialSelected?.contains(i + 1) ?? false,
      };
    });
  }

  List<int> get_chapters() {
    List<int> chapters = [];
    for (int i = 0; i < 30; i++) {
      if (list[i]['checked']) {
        chapters.add(i + 1);
      }
    }
    return chapters;
  }

  void _openBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 5,
                    width: 40,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const Text(
                    "اختر الأجزاء المحفوظة",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const Divider(),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: list.length,
                      itemBuilder: (context, i) {
                        return CheckboxListTile(
                          value: list[i]['checked'],
                          activeColor: Colors.green,
                          title: Text(list[i]['name']),
                          secondary: const Icon(Icons.menu_book_outlined,
                              color: Colors.green),
                          onChanged: (v) {
                            setModalState(() {
                              list[i]['checked'] = v!;
                            });
                            setState(() {}); // يحدث الزر فوق مباشرة
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 30),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "تم",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = get_chapters();

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(45),
          ),
          backgroundColor: Colors.green.shade600,
          foregroundColor: Colors.white,
          elevation: 6,
          shadowColor: Colors.greenAccent.withOpacity(0.5),
        ),
        icon: const Icon(Icons.bookmark_added_outlined, size: 22),
        label: Text(
          selected.isEmpty
              ? "تحديد الأجزاء المحفوظة"
              : "الأجزاء: ${selected.join(', ')}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        onPressed: () => _openBottomSheet(context),
      ),
    );
  }

  static final List<String> juz_list = Quraansoarmanage.AzaaList;
}
