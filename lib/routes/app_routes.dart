import 'package:architect_schwarz_admin/views/pages/categories_page.dart';
import 'package:architect_schwarz_admin/views/pages/home_page.dart';
import 'package:architect_schwarz_admin/views/pages/login_page.dart';

import 'package:get/get.dart';

class RoutesClass {
  static String home = '/';
  static String loginPage = '/login';
  static String categoriesPage = '/main_categories';

  static String getHomeRoute() => home;
  static String getLoginPageRoute() => loginPage;
  static String getCategoriesPageRoute() => categoriesPage;

  static List<GetPage> routes = [
    GetPage(
        page: () => HomePage(),
        name: home,
        transition: Transition.fade,
        transitionDuration: Duration(milliseconds: 500)),
    GetPage(
        page: () => LoginScreen(),
        name: loginPage,
        transition: Transition.fade,
        transitionDuration: Duration(milliseconds: 500)),
    GetPage(
      page: () => CategoriesPage(),
      name: '/main_categories',
      transition: Transition.fade,
      transitionDuration: Duration(milliseconds: 500),
    )
  ];
}
