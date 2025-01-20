import 'package:flutter/material.dart';
import 'package:studentoglasi_mobile/screens/accommodations_screen.dart';
import 'package:studentoglasi_mobile/screens/internships_screen.dart';
import 'package:studentoglasi_mobile/screens/main_screen.dart';
import 'package:studentoglasi_mobile/screens/scholarships_screen.dart';

class MobileBottomNavigationBar extends StatelessWidget {
  final int currentIndex;

  const MobileBottomNavigationBar({
    Key? key,
    required this.currentIndex
  }) : super(key: key);

  void _navigateToScreen(BuildContext context, int index) {
    Widget screen;

    switch (index) {
      case 0:
        screen = ObjavaListScreen();
        break;
      case 1:
        screen = ScholarshipsScreen();
        break;
      case 2:
        screen = InternshipsScreen();
        break;
      case 3:
        screen = AccommodationsScreen();
        break;
      default:
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => screen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: (index) {
        _navigateToScreen(context, index); 
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Novosti',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school),
          label: 'Stipendije',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.work),
          label: 'Prakse',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home_work),
          label: 'Smještaji',
        ),
      ],
    );
  }
}
