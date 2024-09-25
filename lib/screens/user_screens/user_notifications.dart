import 'dart:developer';

import 'package:flutter/material.dart';

class UserNotifications extends StatelessWidget {
   final firstScrollController = ScrollController();
   final secondScrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: ListView(
        controller: secondScrollController,
        children: [
          Notification(),
        ],
      ),
    );
  }

}


class Notification extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    
    return SizedBox(
      height: 140,
      child: Card(
          margin: EdgeInsets.only(bottom: 7 , left: 12 , right: 5),
          color: Colors.white,
          child: Row(
            children: [
              Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    height: 70,
                    width: 70,
                    child: Center(
                        child: Icon(Icons.notifications_none_outlined,
                          size: 45,
                          color: Colors.lightGreen,
                        )
                    ),
                  )
              ),
              Column(
                children: [
                  SizedBox(
                    height: 40,
                    child: Center(
                      child: SizedBox(
                        height: 20,
                      ),
                    )
                  ),
                  SizedBox(
                    height: 100,
                  )
                ],
              )
            ],
          )
      ),
    );
  }
}