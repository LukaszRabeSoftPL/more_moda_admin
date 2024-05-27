import 'package:get/get.dart';

class MenuController extends GetxController {
  var currentIndex =
      0.obs; // Obserwowalna zmienna przechowująca indeks aktywnej strony

  void changePage(int index) {
    currentIndex.value = index; // Aktualizacja obecnej strony
  }
}
