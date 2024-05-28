import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import '../controllers/login_controller.dart';
import '../pages/signup.dart';
import 'chat_page.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());

    return Scaffold(
      body: GetBuilder<LoginController>(
        builder: (_) => SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Form(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Image.asset(
                        "assets/images/logo.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: controller.usernameController,
                      decoration: const InputDecoration(
                        labelText: "Username",
                        labelStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: controller.passwordController,
                      onChanged: (value) {
                        print(controller.passwordController.text);
                      },
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: const TextStyle(color: Colors.grey),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.obscureText
                                ? Icons.lock
                                : Icons.lock_open,
                          ),
                          onPressed: controller.togglePasswordVisibility,
                        ),
                      ),
                      obscureText: controller.obscureText,
                    ),
                    const SizedBox(height: 35),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () async {
                          final controller = Get.find<LoginController>();
                          await controller.handleLogin();
                          if (controller.token != null) {
                            // Create an instance of ChatController and pass the token
                            Get.put(ChatController(token: controller.token!));
                            Get.to(
                              () => ChatPage(),
                              arguments: controller.token,
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.black,
                        ),
                        child: const Text(
                          "Login",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const SignUp()), // Change this
                          );
                        },
                        child: const Text(
                          "Don't have an account? Signup",
                          style: TextStyle(fontSize: 16),
                        ))
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
