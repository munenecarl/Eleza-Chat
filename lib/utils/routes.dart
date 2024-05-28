import 'package:get/get.dart';

import '../pages/chat_page.dart';
import '../pages/login.dart';
import '../pages/signup.dart';

class Routes {
  static final routes = [
    GetPage(name: "/", page: () => const Login()),
    GetPage(name: "/signup", page: () => const SignUp()),
    GetPage(name: "/chat", page: () => const ChatPage()),
  ];
}
