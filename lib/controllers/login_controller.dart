import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../pages/chat_page.dart';

class LoginController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscureText = true;
  String? token;

  void togglePasswordVisibility() {
    obscureText = !obscureText;
    update();
  }

  Future<http.Response?> login(String username, String password) async {
    final url = Uri.parse('http://localhost:3000/login');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'username': username, 'password': password});

    try {
      final response = await http.post(url, headers: headers, body: body);
      return response;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<void> handleLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final username = usernameController.text;
    final password = passwordController.text;
    final response = await login(username, password); // Store the response

    if (response != null) {
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        token = data['token'];
        await prefs.setString('username', username);
        await prefs.setString('token', token!);
        print('Token: $token');
        // Navigate to the chat page
        Get.to(() => const ChatPage(),
            arguments: token); // Pass the token as an argument
      } else if (response.statusCode == 404) {
        // Show an error message
        Get.snackbar(
          'Login Failed',
          'User not found. Please create a new account.',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        // Show a generic error message
        Get.snackbar(
          'Login Failed',
          'Failed to log in. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } else {
      // Show an error message
      Get.snackbar(
        'Login Failed',
        'Failed to log in. Please check your network connection.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
