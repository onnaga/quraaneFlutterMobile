
import 'package:flutter/material.dart';
import 'package:masjed/screens/user_Ranking_screen/list_content_for_ranking_page.dart';

class RankView extends StatelessWidget {
  final bool global;

  const RankView(this.global, {super.key});

  @override
  Widget build(BuildContext context) {
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: const BorderDirectional(
          start: BorderSide(width: 1.5, color: Colors.black26),
          end: BorderSide(width: 1.5, color: Colors.black26),
        ),
      ),
      child: Column(
        children: [

          ListContentForRankingPage(global),
        ],
      ),
    );
  }
}
