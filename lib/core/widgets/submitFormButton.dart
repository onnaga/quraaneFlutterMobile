

import 'package:flutter/material.dart';

class submitFormButton extends StatelessWidget {
   final void Function()  submit ;
  const submitFormButton({
    super.key,
    required this.submit
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: ElevatedButton(
        onPressed: () {

             ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(milliseconds: 3500),
            closeIconColor: Colors.white,
            showCloseIcon: true,
            backgroundColor: Color.fromARGB(255, 230, 14, 14),
            content: Text(
              '  تأكد من عدم إضافة بيانات في الحقول الأخيرة واضغط مطولا للإضافة',
              style: TextStyle(color: Colors.white ,fontWeight: FontWeight.bold),
            ),
          ),
        );
        
        },
          onLongPress: () {
              this.submit();
          },


        
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            side: BorderSide.none,
            shape: const StadiumBorder()),
        child: const Text('إضافة',
            style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
