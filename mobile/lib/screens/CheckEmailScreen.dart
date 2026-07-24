import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'LoginScreen.dart';

class CheckEmailScreen extends StatefulWidget {
  final String email;

  const CheckEmailScreen({
    super.key,
    required this.email,
  });

  @override
  State<CheckEmailScreen> createState() => _CheckEmailScreenState();
}

class _CheckEmailScreenState extends State<CheckEmailScreen> {
  String message = "";
  bool isLoading = false;
  bool isError = false;

  Future<void> handleResendEmail() async {
    setState(() {
      isLoading = true;
      message = "";
      isError = false;
    });

    try {
      final response = await http.post(
        Uri.parse(
          "https://monetee.xyz/api/auth/resend-verification",
        ),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": widget.email,
        }),
      );

      final dynamic decodedBody = jsonDecode(response.body);
      final Map<String, dynamic> data =
          decodedBody is Map<String, dynamic> ? decodedBody : {};

      debugPrint("Resend status: ${response.statusCode}");
      debugPrint("Resend response: ${response.body}");

      if (!mounted) return;

      if (response.statusCode < 200 || response.statusCode >= 300) {
        setState(() {
          isError = true;
          message = data["error"]?.toString() ??
              "Unable to resend verification email.";
        });
        return;
      }

      setState(() {
        isError = false;
        message = data["message"]?.toString() ??
            "Verification email has been sent!";
      });
    } on FormatException {
      if (!mounted) return;

      setState(() {
        isError = true;
        message = "The server returned an invalid response.";
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isError = true;
        message = "Unable to contact the server.";
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
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
                      "assets/images/New Sign Up.png",
                      width: 230,
                      height: 230,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          "assets/images/MoneteeLogo.png",
                          width: 220,
                          height: 220,
                          fit: BoxFit.contain,
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(
                        maxWidth: 500,
                      ),
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 25,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Verify Your Email",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Your BudgetPet account has been created!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              height: 1.7,
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            "We've sent a verification email to",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              height: 1.7,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.email,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF345612),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Please click the link in that email to activate your account.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              height: 1.7,
                            ),
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            "Didn't receive it?",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed:
                                isLoading ? null : handleResendEmail,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFF345212),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  const Color(0xFF345212)
                                      .withOpacity(0.7),
                              disabledForegroundColor: Colors.white70,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: Text(
                              isLoading
                                  ? "Sending..."
                                  : "Resend Verification Email",
                            ),
                          ),
                          if (message.isNotEmpty) ...[
                            const SizedBox(height: 15),
                            Text(
                              message,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isError
                                    ? const Color(0xFFFF0000)
                                    : const Color(0xFF345612),
                                fontSize: 15,
                              ),
                            ),
                          ],
                          const SizedBox(height: 25),
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment:
                                WrapCrossAlignment.center,
                            children: [
                              const Text(
                                "Already verified? ",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                              TextButton(
                                onPressed:
                                    isLoading ? null : goToLogin,
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      const Color(0xFF345612),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 2,
                                  ),
                                ),
                                child: const Text(
                                  "Login",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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