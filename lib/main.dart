
import 'package:flutter/material.dart';

// Container Widget
import 'package:rpl2/container_widget/LatihanContainer.dart';

// Row & Column Widget
import 'package:rpl2/row_column_widget/ColumnWidget.dart';
import 'package:rpl2/row_column_widget/RowWidget.dart';
import 'package:rpl2/row_column_widget/RowColumnWidget.dart';
import 'package:rpl2/row_column_widget/LatihanSatu.dart';
import 'package:rpl2/row_column_widget/LatihanDua.dart';

// SizedBox, Expanded & Stack
import 'package:rpl2/sized_expanded_stack/SizedBoxWidget.dart';
import 'package:rpl2/sized_expanded_stack/ExpandedWidget.dart';
import 'package:rpl2/sized_expanded_stack/StackWidget.dart';
import 'package:rpl2/sized_expanded_stack/LatihanTiga.dart';
import 'package:rpl2/sized_expanded_stack/LayoutSatu.dart';
import 'package:rpl2/sized_expanded_stack/LayoutDua.dart';
import 'package:rpl2/sized_expanded_stack/LayoutTiga.dart';
import 'package:rpl2/sized_expanded_stack/LatihanLayout.dart';

// ListView & GridView
import 'package:rpl2/list_grid_view/ListView.dart';
import 'package:rpl2/list_grid_view/ListView.builder.dart';
import 'package:rpl2/list_grid_view/ListView.separated.dart';
import 'package:rpl2/list_grid_view/GridView.basic.dart';
import 'package:rpl2/list_grid_view/GridView.builder.dart';
import 'package:rpl2/list_grid_view/Instagram.dart';
import 'package:rpl2/list_grid_view/GridScreen.dart';
import 'package:rpl2/list_grid_view/GridProduct.dart';

// Pages
import 'package:rpl2/pages/home_page.dart';
import 'package:rpl2/pages/about_page.dart';
import 'package:rpl2/pages/formulir.dart';
import 'package:rpl2/pages/input_page.dart';
import 'package:rpl2/pages/output_page.dart';
import 'package:rpl2/pages/store_page.dart';
import 'package:rpl2/pages/Album_page.dart';
import 'package:rpl2/pages/post_page.dart';

// Routes
import 'package:rpl2/routes/app_routes.dart';

// Authentication
import 'pages/home.dart';
import 'pages/login_page.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final token = await AuthService().getToken();

  runApp(MyApp(isLoggedIn: token != null));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({
    super.key,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      initialRoute: isLoggedIn ? '/' : '/login',

      routes: {
        ...AppRoutes.routes,

        '/login': (context) => const LoginPage(),
      },
    );
  }
}
