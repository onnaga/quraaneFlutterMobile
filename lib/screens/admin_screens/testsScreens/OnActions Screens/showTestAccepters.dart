import 'package:flutter/material.dart';
import 'package:masjed/models/objects.dart';
import 'package:masjed/screens/admin_screens/testsScreens/OnActions%20Screens/edite_user_test_data.dart';
import 'package:masjed/state/user.dart';
import 'package:provider/provider.dart';
import 'package:masjed/state/profile.dart'; // ✅ Added import

// =========================================================================
// 1. الشاشة الرئيسية (Main Screen)
// =========================================================================
class UserTestListViewAccepters extends StatefulWidget {
  final List<TestUserAccepters> initialData;
  final int testId;

  const UserTestListViewAccepters({
    super.key,
    required this.initialData,
    required this.testId,
  });

  @override
  State<UserTestListViewAccepters> createState() =>
      _UserTestListViewAcceptersState();
}

class _UserTestListViewAcceptersState extends State<UserTestListViewAccepters> {
  late List<TestUserAccepters> data;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    data = List.from(widget.initialData);
  }

  Future<void> _refreshData() async {
    setState(() => isLoading = true);
    try {
      final profile = Provider.of<Profile>(context, listen: false);
      final newData = await profile.show_test_accepters(widget.testId);
      setState(() {
        data = newData;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('فشل تحديث القائمة: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _deleteStudent(int userId) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('الغاء تسجيل الطالب؟'),
        content: const Text('هل أنت متأكد من إلغاء تسجيل هذا الطالب من السبر؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('لا')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('نعم')),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => isLoading = true);
    try {
      if (!mounted) return;
      await Provider.of<Profile>(context, listen: false)
          .delete_accepted_test_for_student(widget.testId, userId);

      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('تم حذف المتقدم بنجاح')));

      _refreshData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
      setState(() => isLoading = false);
    }
  }

  void _showAddStudentDialog() {
    int? selectedStudentId;
    List<OneUserRank>? studentsList;
    bool isDialogLoading = true;
    bool isAdding = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            if (isDialogLoading && studentsList == null) {
              final profile = Provider.of<Profile>(context, listen: false);
              final user = Provider.of<User>(context, listen: false);

              // daoraId comes from user profile usually, or Daorastate
              // But 'get_rank' requires daoraId. Let's try to pass 0 if we don't know,
              // or get it from provider. If user is teacher, get_rank ignores daoraId.
              // If user is supervisor, we need daoraId.
              int daoraId = user.daoraId;

              bool global = user.privilege == 3;
              profile.get_rank(global, daoraId).then((res) {
                if (mounted) {
                  setDialogState(() {
                    if (res['success'] == true) {
                      studentsList = profile.RankUsers;
                    } else {
                      studentsList = [];
                    }
                    isDialogLoading = false;
                  });
                }
              }).catchError((e) {
                if (mounted) {
                  setDialogState(() {
                    studentsList = [];
                    isDialogLoading = false;
                  });
                }
              });
            }

            return AlertDialog(
              title: const Text('إضافة طالب للسبر'),
              content: SizedBox(
                height:
                    200, // Increased height to comfortably show the autocomplete options
                width: double
                    .maxFinite, // Ensures the dialog takes available width
                child: isDialogLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Autocomplete<OneUserRank>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text == '') {
                            return studentsList ??
                                const Iterable<OneUserRank>.empty();
                          }
                          return (studentsList ?? [])
                              .where((OneUserRank option) {
                            return option.user_name
                                .toLowerCase()
                                .contains(textEditingValue.text.toLowerCase());
                          });
                        },
                        displayStringForOption: (OneUserRank option) =>
                            option.user_name,
                        fieldViewBuilder: (BuildContext context,
                            TextEditingController fieldTextEditingController,
                            FocusNode fieldFocusNode,
                            VoidCallback onFieldSubmitted) {
                          // Listen to text changes to reset the selection if the user clears the text
                          fieldTextEditingController.addListener(() {
                            if (fieldTextEditingController.text.isEmpty &&
                                selectedStudentId != null) {
                              setDialogState(() {
                                selectedStudentId = null;
                              });
                            }
                          });

                          return TextField(
                            controller: fieldTextEditingController,
                            focusNode: fieldFocusNode,
                            decoration: const InputDecoration(
                              hintText: 'ابحث عن طالب...',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.search),
                            ),
                          );
                        },
                        onSelected: (OneUserRank selection) {
                          setDialogState(() {
                            selectedStudentId = selection.user_id;
                          });
                        },
                        optionsViewBuilder: (BuildContext context,
                            AutocompleteOnSelected<OneUserRank> onSelected,
                            Iterable<OneUserRank> options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 4.0,
                              child: SizedBox(
                                height: 200.0,
                                width: MediaQuery.of(context).size.width *
                                    0.7, // Adjust width as needed
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  itemCount: options.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final OneUserRank option =
                                        options.elementAt(index);
                                    return ListTile(
                                      title: Text(option.user_name),
                                      onTap: () {
                                        onSelected(option);
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      isAdding ? null : () => Navigator.pop(dialogContext),
                  child: const Text('إلغاء'),
                ),
                FilledButton(
                  onPressed: (isAdding || selectedStudentId == null)
                      ? null
                      : () async {
                          setDialogState(() => isAdding = true);
                          try {
                            final profile =
                                Provider.of<Profile>(context, listen: false);
                            await profile.accept_test_for_student(
                                widget.testId, selectedStudentId!);
                            if (mounted) {
                              Navigator.pop(dialogContext);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('تم تسجيل الطالب بنجاح'),
                                    backgroundColor: Colors.green),
                              );
                              _refreshData();
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(e.toString()),
                                    backgroundColor: Colors.red),
                              );
                              setDialogState(() => isAdding = false);
                            }
                          }
                        },
                  child: isAdding
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('إضافة'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final int userPrivilege =
        Provider.of<User>(context, listen: false).privilege ?? 0;
    final bool canAdd = userPrivilege == 2 || userPrivilege == 3;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          "الطلاب المتقدمون للسبر",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      floatingActionButton: canAdd
          ? FloatingActionButton.extended(
              onPressed: _showAddStudentDialog,
              backgroundColor: Colors.green,
              icon: const Icon(Icons.person_add, color: Colors.white),
              label: const Text("إضافة طالب",
                  style: TextStyle(color: Colors.white)),
            )
          : null,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : data.isEmpty
              ? const Center(
                  child: Text(
                    "لا يوجد متقدمين بعد",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refreshData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      if (userPrivilege == 1) {
                        return StudentInfoCard(userInfo: data[index]);
                      } else {
                        return Stack(
                          children: [
                            UserTestEditorForm(initialUserInfo: data[index]),
                            if (canAdd)
                              Positioned(
                                top: 8,
                                left: 8,
                                child: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () =>
                                      _deleteStudent(data[index].user_id),
                                ),
                              ),
                          ],
                        );
                      }
                    },
                  ),
                ),
    );
  }
}

// =========================================================================
// 2. واجهة عرض بيانات الطالب (للمستخدم العادي) - Reusable Card
// =========================================================================
class StudentInfoCard extends StatelessWidget {
  final TestUserAccepters userInfo;

  const StudentInfoCard({super.key, required this.userInfo});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(Icons.person, "اسم الطالب", userInfo.user_name),
            const Divider(height: 20),
            _buildInfoRow(Icons.star, "التقدير", userInfo.rating),
            const SizedBox(height: 12),
            _buildInfoRow(
                Icons.book, "أرقام الأجزاء", userInfo.the_part_to_test_in),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.notes, "الملاحظات", userInfo.notes),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.green, size: 20),
        const SizedBox(width: 12),
        Text(
          "$label: ",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }
}
