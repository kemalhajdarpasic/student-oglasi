import 'package:flutter/material.dart';

class NavBarMobile extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController naslovController;
  final VoidCallback onSearchChanged;

  NavBarMobile({
    required this.naslovController,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.only(bottom: 12.0),
            child: TextField(
              controller: naslovController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Pretraži...',
                hintStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 1),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 1),
                ),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 1),
                ),
              ),
              onChanged: (text) => onSearchChanged(),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.search, color: Colors.white),
          onPressed: onSearchChanged,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
