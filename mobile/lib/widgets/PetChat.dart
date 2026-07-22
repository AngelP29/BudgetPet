import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class PetChat extends StatefulWidget {
  const PetChat({super.key});

  @override
  State<PetChat> createState() => _PetChatState();
}

class _PetChatState extends State<PetChat> {
  final messageController = TextEditingController();

  String petReply = "Hey! Ready to float through your finances today?";
  String errorMessage = "";
  bool isLoading = false;

  Future<void> petConversation() async {
    final message = messageController.text.trim();

    setState(() {
      errorMessage = "";
    });

    if (message.isEmpty) {
      setState(() {
        errorMessage = "Please enter a message for your pet.";
      });
      return;
    }
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString("token");
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      setState(() {
        errorMessage = "Missing login token. Please log in again.";
      });
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.post(
        Uri.parse("https://monetee.xyz/api/chat"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "message": message,
          "petName": "BudgetPet",
        }),
      );
      
      final dynamic decodedBody = jsonDecode(response.body);
      final Map<String, dynamic> data =
          decodedBody is Map<String, dynamic> ? decodedBody : {};

      if (response.statusCode != 200) {
        if (!mounted) {
          return;
        }

        setState(() {
          errorMessage = data["error"]?.toString() ??
              "Failed to chat with pet. Try again soon.";
        });
        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        petReply =
            data["reply"]?.toString() ?? "Your pet had nothing to say.";
        messageController.clear();
      });
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
        errorMessage = "Unable to connect to the pet right now.";
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
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.all(14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFE5E7EB),
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
    );
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 10,
          sigmaY: 10,
        ),
        child: Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Center(

                child: Text(
                  "Pet Coach",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF333333),
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
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  petReply,
                  style: const TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 16,
                    height: 1.5,
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
                textInputAction: TextInputAction.send,
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
                  onPressed: isLoading ? null : petConversation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF53C9A8),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        const Color(0xFF53C9A8).withOpacity(0.7),
                    disabledForegroundColor: Colors.white70,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Text(
                    isLoading ? "Sending..." : "Send",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}