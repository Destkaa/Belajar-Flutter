import 'package:flutter/material.dart';

import 'package:rpl2/container_widget/LatihanContainer.dart';

import 'package:rpl2/row_column_widget/ColumnWidget.dart';
import 'package:rpl2/row_column_widget/RowWidget.dart';
import 'package:rpl2/row_column_widget/RowColumnWidget.dart';
import 'package:rpl2/row_column_widget/LatihanSatu.dart';
import 'package:rpl2/row_column_widget/LatihanDua.dart';

import 'package:rpl2/sized_expanded_stack/SizedBoxWidget.dart';
import 'package:rpl2/sized_expanded_stack/ExpandedWidget.dart';
import 'package:rpl2/sized_expanded_stack/StackWidget.dart';
import 'package:rpl2/sized_expanded_stack/LatihanTiga.dart';
import 'package:rpl2/sized_expanded_stack/LayoutSatu.dart';
import 'package:rpl2/sized_expanded_stack/LayoutDua.dart';
import 'package:rpl2/sized_expanded_stack/LayoutTiga.dart';
import 'package:rpl2/sized_expanded_stack/LatihanLayout.dart';

import 'package:rpl2/list_grid_view/ListView.dart';
import 'package:rpl2/list_grid_view/ListView.builder.dart';
import 'package:rpl2/list_grid_view/ListView.separated.dart';
import 'package:rpl2/list_grid_view/GridView.basic.dart';
import 'package:rpl2/list_grid_view/GridView.builder.dart';
import 'package:rpl2/list_grid_view/Instagram.dart';
import 'package:rpl2/list_grid_view/GridScreen.dart';
import 'package:rpl2/list_grid_view/GridProduct.dart';

import 'package:rpl2/pages/home_page.dart';
import 'package:rpl2/pages/about_page.dart';

import 'package:rpl2/routes/app_routes.dart';

import 'package:rpl2/pages/formulir.dart';
import 'package:rpl2/pages/input_page.dart';
import 'package:rpl2/pages/output_page.dart';

import 'package:rpl2/pages/store_page.dart';
import 'package:rpl2/pages/Album_page.dart';
import 'pages/post_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override

  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: AppRoutes.routes,
      // home: formulir(),
    );
  }
}

// import 'package:flutter/material.dart';

// import 'pages/post_page.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Fetch API Demo',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
//       home: const PostPage(),
//     );
//   }
// }