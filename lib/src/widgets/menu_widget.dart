import 'package:flutter/material.dart';

class MenuWidget extends BottomNavigationBar {
  MenuWidget({super.key, required super.items});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: items,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    );
  }
}