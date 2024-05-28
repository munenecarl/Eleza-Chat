import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/chat_controller.dart';
import '../pages/login.dart';
import 'package:http/http.dart' as http;

class LogoutController extends GetxController {
  Future<void> logout() async {
    final url = Uri.parse('http://localhost:3000/logout');
    final headers = {'Content-Type': 'application/json'};

    try {
      final response = await http.post(url, headers: headers);

      if (response.statusCode == 200) {
        print('Logged out successfully');

        // Call the onClose method of ChatController to disconnect the socket
        Get.find<ChatController>().onClose();

        // Clear shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        // Navigate to the first page of your app
        Get.offAll(Login()); // Replace FirstPage with your actual first page
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
