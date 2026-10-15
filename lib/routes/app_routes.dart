import 'package:flutter/material.dart';
import 'package:rpl2/pages/home_page.dart';
import 'package:rpl2/pages/about_page.dart';
import 'package:rpl2/list_grid_view/Instagram.dart';
import 'package:rpl2/pages/formulir.dart';

class AppRoutes {
  static const String home = '/';
  static const String about = '/about';
  static const String Instagram = '/Instagram';
  static const String formulir = '/formulir';

  static final Map<String, WidgetBuilder> routes = {
    home: (context) => HomePage(),
    about: (context) => AboutPage(),
    Instagram: (context) => BerandaInstagram(),
    formulir: (context) => Formulir(),

  };
}