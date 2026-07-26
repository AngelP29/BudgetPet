import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'DashboardScreen.dart';
import 'SignupScreen.dart';
import 'dart:ui';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
  with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;
  late final Animation<double> _floatAnimation;
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  String errorMessage = "";
  String successMessage = "";
  bool isLoading = false;

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
        Uri.parse("https://monetee.xyz/api/auth/login"),
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
    _floatController.dispose();
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
                      width:240,
                      height:240,
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
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Build better financial habits alongside your virtual companion Monetee!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
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
                            color: Color(0xFF1A1A1A),
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SignupScreen(),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF345612),
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

                        const SizedBox(height: 18),

                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Text(
                              "Forgot your password? ",
                              style: TextStyle(
                                color: Color(0xFF333333),
                                fontSize: 15,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => const ForgotPasswordDialog(),
                                );
                              },        
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF345612),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                "Reset it",
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
class ForgotPasswordDialog extends StatefulWidget {
  const ForgotPasswordDialog({super.key});

  @override
  State<ForgotPasswordDialog> createState() =>
      _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog>
    with SingleTickerProviderStateMixin {
  final TextEditingController emailController =
      TextEditingController();

  late final AnimationController floatingController;
  late final Animation<double> floatingAnimation;

  bool isLoading = false;
  bool isSubmitted = false;

  String errorMessage = "";
  String submittedEmail = "";

  @override
  void initState() {
    super.initState();

    floatingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    floatingAnimation = Tween<double>(
      begin: -8,
      end: 8,
    ).animate(
      CurvedAnimation(
        parent: floatingController,
        curve: Curves.easeInOut,
      ),
    );

    floatingController.repeat(
      reverse: true,
    );
  }

  Future<void> sendResetEmail() async {
    final String email =
        emailController.text.trim().toLowerCase();

    setState(() {
      errorMessage = "";
    });

    if (email.isEmpty) {
      setState(() {
        errorMessage =
            "Please enter your email address.";
      });

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(
          "https://monetee.xyz/api/auth/requestReset",
        ),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": email,
        }),
      );

      Map<String, dynamic> data = {};

      try {
        data = jsonDecode(response.body)
            as Map<String, dynamic>;
      } catch (_) {
        data = {};
      }

      if (!mounted) {
        return;
      }

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        setState(() {
          submittedEmail = email;
          isSubmitted = true;
        });
      } else {
        setState(() {
          errorMessage =
              data["error"]?.toString() ??
                  data["message"]?.toString() ??
                  "Unable to send reset email.";
        });
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        errorMessage =
            "Unable to connect to the server.";
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    floatingController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 24,
      ),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(28),
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
        child: SingleChildScrollView(
          child: isSubmitted
              ? _buildSubmittedView()
              : _buildEmailForm(),
        ),
      ),
    );
  }

  Widget _buildSubmittedView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),

        AnimatedBuilder(
          animation: floatingAnimation,
          child: Image.asset(
            "assets/images/Monetee.png",
            height: 150,
            fit: BoxFit.contain,
          ),
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                0,
                floatingAnimation.value,
              ),
              child: child,
            );
          },
        ),

        const SizedBox(height: 24),

        const Text(
          "If an account exists under the email:",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontSize: 15,
            height: 1.6,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          submittedEmail,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF345612),
            fontSize: 16,
            fontWeight: FontWeight.bold,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 12),

        const Text(
          "We'll send you an email with password reset instructions.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontSize: 15,
            height: 1.6,
          ),
        ),

        const SizedBox(height: 28),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(0xFF345612),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                vertical: 15,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              "Ok!",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
  
        const SizedBox(height: 6),

        const Text(
          "Reset Your Password",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 14),

        const Text(
          "Please enter the email related to your account:",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Color(0xFF1A1A1A),
          ),
        ),

        const SizedBox(height: 22),

        TextField(
          controller: emailController,
          keyboardType:
              TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autocorrect: false,
          enableSuggestions: false,
          onSubmitted: (_) {
            if (!isLoading) {
              sendResetEmail();
            }
          },
          decoration: InputDecoration(
            hintText: "Your email address",
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.all(15),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF56CEC0),
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF56CEC0),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
          ),
        ),

        if (errorMessage.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 14,
            ),
          ),
        ],

        const SizedBox(height: 22),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                isLoading ? null : sendResetEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(0xFF345612),
              foregroundColor: Colors.white,
              disabledBackgroundColor:
                  const Color(0xFF345612)
                      .withOpacity(0.7),
              padding: const EdgeInsets.symmetric(
                vertical: 15,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(14),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    "Reset Password",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}