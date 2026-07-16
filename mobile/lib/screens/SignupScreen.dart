import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'DashboardScreen.dart';
import 'LoginScreen.dart';


class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;
  late final Animation<double> _floatAnimation;
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String errorMessage = "";
  String successMessage = "";
  bool isLoading = false;

  final RegExp passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z\d]).{8,}$',
  );

  Future<void> handleSignup() async {
    setState(() {
      errorMessage = "";
      successMessage = "";
    });

    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      setState(() {
        errorMessage = "Please fill in all fields.";
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        errorMessage = "Passwords do not match.";
      });
      return;
    }

    if (!passwordRegex.hasMatch(password)) {
      setState(() {
        errorMessage =
            "Password must be at least 8 characters and include uppercase, lowercase, a number, and a special character.";
      });
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.post(
        Uri.parse("https://monetee.xyz/api/auth/register"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "firstName": firstName,
          "lastName": lastName,
          "username": username,
          "email": email,
          "password": password,
        }),
      );

      final dynamic decodedBody = jsonDecode(response.body);
      final Map<String, dynamic> data =
          decodedBody is Map<String, dynamic> ? decodedBody : {};

      if (response.statusCode != 201) {
        if (!mounted) {
          return;
        }

        setState(() {
          errorMessage = data["error"]?.toString() ?? "Signup failed.";
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

      if (!mounted) {
        return;
      }

      setState(() {
        successMessage = "Account created successfully! Redirecting...";
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
    } on FormatException {
      if (!mounted) {
        return;
      }

      setState(() {
        errorMessage = "The server returned an invalid response.";
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        errorMessage = "Unable to connect to the server.";
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFFF0000),
          width: 2,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

     _floatController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

     _floatAnimation = Tween<double>(
        begin: -5,
        end: 5,
    ).animate(
       CurvedAnimation(
         parent: _floatController,
         curve: Curves.easeInOut,
        ),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
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
                    AnimatedBuilder(
                       animation: _floatAnimation,
                       builder: (context, child) {
                         return Transform.translate(
                            offset: Offset(0, _floatAnimation.value),
                            child: Transform.rotate(
                              angle: _floatAnimation.value * 0.003,
                              child: child,
                            ),

                        );
                      },
                      child: Image.asset(
                        "assets/images/MoneteeLogo.png",
                        width: 220,
                        height: 220,
                        fit: BoxFit.contain,
                      ),
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
                      width: 420,
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 40,
                            offset: const Offset(0, 20),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Create Account",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Join BudgetPet today!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF777777),
                            ),
                          ),
                          const SizedBox(height: 28),
                          TextField(
                            controller: firstNameController,
                            textInputAction: TextInputAction.next,
                            decoration: _inputDecoration("First Name"),
                          ),
                          const SizedBox(height: 18),
                          TextField(
                            controller: lastNameController,
                            textInputAction: TextInputAction.next,
                            decoration: _inputDecoration("Last Name"),
                          ),
                          const SizedBox(height: 18),
                          TextField(
                            controller: usernameController,
                            textInputAction: TextInputAction.next,
                            decoration: _inputDecoration("Username"),
                          ),
                          const SizedBox(height: 18),
                          TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: _inputDecoration("Email"),
                          ),
                          const SizedBox(height: 18),
                          TextField(
                            controller: passwordController,
                            obscureText: true,
                            textInputAction: TextInputAction.next,
                            decoration: _inputDecoration("Password"),
                          ),
                          const SizedBox(height: 18),
                          TextField(
                            controller: confirmPasswordController,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) {
                              if (!isLoading) {
                                handleSignup();
                              }
                            },
                            decoration: _inputDecoration("Confirm Password"),
                          ),
                          if (errorMessage.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            Text(
                              errorMessage,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFFFF0000),
                                fontSize: 14,
                                height: 1.4,
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
                                height: 1.4,
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : handleSignup,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF345612),
                                foregroundColor: Colors.white,
                                disabledBackgroundColor:
                                    const Color(0xFF345612).withOpacity(0.7),
                                disabledForegroundColor: Colors.white70,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: Text(
                                isLoading
                                    ? "Creating Account..."
                                    : "Create Account",
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              const Text(
                                "Already have an account? ",
                                style: TextStyle(
                                  color: Color(0xFF333333),
                                  fontSize: 15,
                                ),
                              ),
                              TextButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const LoginScreen(),
                                          ),
                                        );
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
                                  "Log In",
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