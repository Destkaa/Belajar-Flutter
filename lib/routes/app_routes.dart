import 'package:flutter/material.dart';
import 'package:rpl2/pages/home_page.dart';
import 'package:rpl2/pages/about_page.dart';
import 'package:rpl2/list_grid_view/Instagram.dart';
import 'package:rpl2/pages/formulir.dart';
import 'package:rpl2/pages/input_page.dart';

class AppRoutes {
  static const String home = '/';
  static const String about = '/about';
  static const String Instagram = '/Instagram';
  static const String formulir = '/formulir';
  static const String input = '/input';


  static final Map<String, WidgetBuilder> routes = {
    home: (context) => HomePage(),
    about: (context) => AboutPage(),
    Instagram: (context) => BerandaInstagram(),
    formulir: (context) => Formulir(),
    input: (context) => BelajarForm(),
  };
}