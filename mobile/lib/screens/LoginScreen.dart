import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'DashboardScreen.dart';
import 'dart:ui';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  String errorMessage = "";
  String successMessage = "";
  bool isLoading = false;

  Future<void> handleLogin() async {
    setState(() {
      errorMessage = "";
      successMessage = "";
    });

    final username = usernameController.text.trim();
    final password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = "Please enter both username and password.";
      });
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.post(
        Uri.parse("http://192.241.249.164/api/auth/login"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "username": username,
          "password": password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        setState(() {
          errorMessage = data["error"] ?? "Login failed.";
        });
        return;
      }

      final preferences = await SharedPreferences.getInstance();

      await preferences.setString(
        "token",
        data["token"]?.toString() ?? "",
      );

      await preferences.setString(
        "userId",
        data["userId"]?.toString() ?? "",
      );

      await preferences.setString(
        "username",
        data["username"]?.toString() ?? username,
      );

      setState(() {
        successMessage = "Login successful.";
      });

      await Future.delayed(const Duration(milliseconds: 700));

      if (!mounted) {
        return;
      }

      Navigator.pushReplacement(
       context,
       MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
        
        ),
      );

    } catch (e) {
      setState(() {
        errorMessage = "Error: Unable to connect to the server.";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(
      color: Color(0xFF777777),
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.all(15),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(
        color: Color(0xFF56CEC0),
        width: 2,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(
        color: Color(0xFF56CEC0),
        width: 2,
      ),
    ),
  );
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            "assets/images/BGMain.png",
            fit: BoxFit.cover,
          ),
        ),

        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 10,
              sigmaY: 10,
            ),
            child: Container(
              color: Colors.black.withOpacity(0.05),
            ),
          ),
        ),

        SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              child: Column(
                children: [
                  Image.asset(
                    "assets/images/MoneteeLogo.png",
                    width: 240,
                    height: 240,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    "BudgetPet",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Build better financial habits alongside your virtual companion Monetee!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  Container(
                    width: 380,
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Welcome Back",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          "Sign in to continue your journey.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF777777),
                          ),
                        ),

                        const SizedBox(height: 28),

                        TextField(
                          controller: usernameController,
                          decoration: _inputDecoration("Username"),
                        ),

                        const SizedBox(height: 18),

                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: _inputDecoration("Password"),
                        ),

                        if (errorMessage.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Text(
                            errorMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFFF0000),
                              fontSize: 14,
                            ),
                          ),
                        ],

                        if (successMessage.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Text(
                            successMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF345612),
                              fontSize: 14,
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF345612),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  const Color(0xFF345612).withOpacity(0.7),
                              disabledForegroundColor: Colors.white70,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: Text(
                              isLoading ? "Logging In..." : "Log In",
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                color: Color(0xFF333333),
                                fontSize: 15,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // Navigate to SignupScreen later
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF4A7DF3),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                "Create one",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
}