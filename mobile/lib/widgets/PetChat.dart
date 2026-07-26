import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PetChat extends StatefulWidget {
  const PetChat({super.key});

  @override
  State<PetChat> createState() => _PetChatState();
}

class _PetChatState extends State<PetChat> {
  final TextEditingController messageController =
      TextEditingController();

  String petReply =
      "Hey! Ready to float through your finances today?";

  String errorMessage = "";
  bool isLoading = false;

  Future<void> petConversation() async {
    final String message =
        messageController.text.trim();

    setState(() {
      errorMessage = "";
    });

    if (message.isEmpty) {
      setState(() {
        errorMessage =
            "Please enter a message for your pet.";
      });

      return;
    }

    final SharedPreferences preferences =
        await SharedPreferences.getInstance();

    final String? token =
        preferences.getString("token");

    if (token == null || token.isEmpty) {
      if (!mounted) {
        return;
      }

      setState(() {
        errorMessage = "Please log in.";
      });

      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final http.Response response =
          await http.post(
        Uri.parse(
          "https://monetee.xyz/api/chat",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "message": message,
          "petName": "BudgetPet",
        }),
      );

      Map<String, dynamic> data = {};

      try {
        final dynamic decodedBody =
            jsonDecode(response.body);

        if (decodedBody is Map<String, dynamic>) {
          data = decodedBody;
        }
      } catch (_) {
        data = {};
      }

      if (!mounted) {
        return;
      }

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        setState(() {
          petReply =
              data["reply"]?.toString() ??
              "Your pet had nothing to say.";

          messageController.clear();
        });
      } else {
        setState(() {
          errorMessage =
              data["error"]?.toString() ??
              data["message"]?.toString() ??
              "Failed to chat with pet. Try again soon.";
        });
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        errorMessage =
            "Unable to connect to the pet right now.";
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      hintText: "Ask your pet anything...",
      hintStyle: const TextStyle(
        color: Color(0xFF777777),
      ),
      filled: true,
      fillColor: const Color(0xFFFAF2E5),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF0077FF),
          width: 2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF58C78D),
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFD64545),
          width: 2,
        ),
      ),
    );
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 35,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              "Pet Coach",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color.fromARGB(255, 0, 0, 0),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            constraints: const BoxConstraints(
              minHeight: 150,
            ),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(15),
            ),
            child: SingleChildScrollView(
              child: Text(
                petReply,
                style: const TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
          ),

          if (errorMessage.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              errorMessage,
              style: const TextStyle(
                color: Color(0xFFD64545),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],

          const SizedBox(height: 14),

          TextField(
            controller: messageController,
            enabled: !isLoading,
            keyboardType: TextInputType.text,
            textInputAction:
                TextInputAction.send,
            onSubmitted: (_) {
              if (!isLoading) {
                petConversation();
              }
            },
            decoration: _inputDecoration(),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  isLoading ? null : petConversation,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF345212),
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    const Color(0xFF345212)
                        .withOpacity(0.7),
                disabledForegroundColor:
                    Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Sending...",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : const Text(
                      "Send",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}