import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studentoglasi_mobile/providers/studenti_provider.dart';

class NavbarDesktop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var studentiProvider = Provider.of<StudentiProvider>(context);
    
    return Container(
      color: Colors.blue,
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildLogo(),
          _buildCenteredNavItems(context),
          studentiProvider.isLoggedIn 
              ? _buildProfileMenu(context) 
              : _buildLoginButton(context),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Text(
      'StudentOglasi',
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    );
  }

  Widget _buildCenteredNavItems(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildNavItem(context, 'POČETNA', Icons.home_outlined, '/home'),
        _buildNavItem(context, 'STIPENDIJE', Icons.school_outlined, '/scholarships'),
        _buildNavItem(context, 'PRAKSE', Icons.work_outline, '/internships'),
        _buildNavItem(context, 'SMJEŠTAJI', Icons.house_outlined, '/accommodations'),
      ],
    );
  }

  Widget _buildNavItem(
      BuildContext context, String title, IconData icon, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextButton.icon(
        onPressed: () {
          Navigator.pushNamed(context, route);
        },
        icon: Icon(icon, color: Colors.white),
        label: Text(
          title,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

   Widget _buildLoginButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).pushNamed('/login');
      },
      style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: Colors.blue,
    ),
      child: Text("Prijavi se"),
    );
  }

  Widget _buildProfileMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.account_circle_outlined, color: Colors.white),
      offset: const Offset(0, 40),
      onSelected: (String value) {
        switch (value) {
          case 'profile':
            Navigator.pushNamed(context, '/profile');
            break;
          case 'prijave':
            Navigator.pushNamed(context, '/prijave');
            break;
          case 'chat':
            Navigator.pushNamed(context, '/chat');
            break;
          case 'obavijesti':
            Navigator.pushNamed(context, '/obavijesti');
            break;
          case 'logout':
            Navigator.pushNamed(context, '/logout');
            break;
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem(
            value: 'profile',
            child: Row(
              children: [
                Icon(Icons.account_circle_outlined, color: Colors.blue),
                SizedBox(width: 8),
                Text('Moj profil'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'prijave',
            child: Row(
              children: [
                Icon(Icons.mail_outline, color: Colors.blue),
                SizedBox(width: 8),
                Text('Moje prijave'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'chat',
            child: Row(
              children: [
                Icon(Icons.chat_bubble_outline, color: Colors.blue),
                SizedBox(width: 8),
                Text('Chat'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'obavijesti',
            child: Row(
              children: [
                Icon(Icons.notification_add_outlined, color: Colors.blue),
                SizedBox(width: 8),
                Text('Obavijesti'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'logout',
            child: Row(
              children: [
                Icon(Icons.logout, color: Colors.blue),
                SizedBox(width: 8),
                Text('Odjavi se'),
              ],
            ),
          ),
        ];
      },
    );
  }
}
