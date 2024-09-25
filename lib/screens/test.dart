import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class App extends StatelessWidget {
  PageController controller = PageController(initialPage:0,keepPage: true);
  GlobalKey<NavigationState> nav_state = GlobalKey<NavigationState>();


  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (f){
        if (controller.page != 0) {
          controller.animateToPage(0,duration: const Duration(milliseconds: 300),curve: Curves.ease);
          return;
        }
        showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) => ExitAlert()
        );
      },
      child: Scaffold(
        body: PageView(
          physics: NeverScrollableScrollPhysics(),
          onPageChanged: (int i){nav_state.currentState?.update(i);},
          controller: controller,
          scrollDirection: Axis.horizontal,
          children: [

          ],
        ),
        bottomNavigationBar: Navigation(controller,key: nav_state),
      ),
    );
  }

}





class Navigation extends StatefulWidget {
  final PageController controller;
  const Navigation(this.controller,{super.key});

  @override
  State<StatefulWidget> createState() => NavigationState();
}

class NavigationState extends State<Navigation> {
  int index = 0;

  void update (int i) {setState(() {index = i;});}

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: index,
      onTap: (i) {widget.controller.animateToPage(i,duration: const Duration(milliseconds: 300),curve: Curves.ease);},
      items: const [

      ],
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.black38,
      showUnselectedLabels: true,
    );
  }
}


class ExitAlert extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 24.0,
      content: const Text('الخروج من التطبيق'),
      actions: [
        TextButton(
          child: const Text('كلا'),
          onPressed: (){Navigator.pop(context);},
        ),
        TextButton(
          child: const Text('نعم'),
          onPressed: (){SystemNavigator.pop(animated: true);},
        ),
      ],
    );
  }
}