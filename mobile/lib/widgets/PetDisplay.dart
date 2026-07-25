import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PetDisplay extends StatefulWidget {
  const PetDisplay({
    super.key,
    required this.refreshTrigger,
  });

  final int refreshTrigger;

  @override
  State<PetDisplay> createState() => _PetDisplayState();
}

class _PetDisplayState extends State<PetDisplay>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? pet;

  String errorMessage = "";
  bool isFetchingPet = false;

  late final AnimationController _floatController;
  late final Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(
      begin: 0,
      end: -8,
    ).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: Curves.easeInOut,
      ),
    );

    loadPet();
  }

  @override
  void didUpdateWidget(covariant PetDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.refreshTrigger != widget.refreshTrigger) {
      loadPet();
    }
  }

  Future<void> loadPet() async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString("token");

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
      if (mounted) {
        setState(() {
          isFetchingPet = true;
          errorMessage = "";
        });
      }

      final response = await http.get(
        Uri.parse(
          "https://monetee.xyz/api/pets",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      Map<String, dynamic> data = {};

      try {
        final decodedBody = jsonDecode(response.body);

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
          pet = data;
        });
      } else {
        setState(() {
          errorMessage =
              data["error"]?.toString() ??
              data["message"]?.toString() ??
              "Failed to load pet information.";
        });
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        errorMessage =
            "Unable to retrieve pet information.";
      });
    } finally {
      if (mounted) {
        setState(() {
          isFetchingPet = false;
        });
      }
    }
  }

  int get petLevel {
    final value = pet?["level"];

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? "",
        ) ??
        1;
  }

  int get petExp {
    final value = pet?["exp"];

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? "",
        ) ??
        0;
  }

  double get petHappiness {
    final value = pet?["happiness"];

    if (value is num) {
      return value.toDouble().clamp(0.0, 100.0);
    }

    return double.tryParse(
          value?.toString() ?? "",
        )?.clamp(0.0, 100.0) ??
        100.0;
  }

  String get petImage {
    final happiness = petHappiness;

    if (pet == null) {
      return "assets/images/Monetee.png";
    }

    if (happiness > 60) {
      return "assets/images/Happy Monetee.gif";
    }

    if (happiness >= 40) {
      return "assets/images/Sad Monetee.gif";
    }

    return "assets/images/Worried Monetee.gif";
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final happiness = petHappiness;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 30,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 22,
      ),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color:
                const Color(0xFF1A5A78).withOpacity(0.18),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (errorMessage.isNotEmpty) ...[
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFD64545),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 15),
          ],

          if (isFetchingPet) ...[
            const Text(
              "Loading pet...",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF666666),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 15),
          ],

          AnimatedBuilder(
            animation: _floatAnimation,
            child: Image.asset(
              petImage,
              width: 250,
              height: 250,
              fit: BoxFit.contain,
              gaplessPlayback: true,
              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return Image.asset(
                  "assets/images/Monetee.png",
                  width: 250,
                  height: 250,
                  fit: BoxFit.contain,
                );
              },
            ),
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  0,
                  _floatAnimation.value,
                ),
                child: child,
              );
            },
          ),

          const SizedBox(height: 10),

          const Text(
            "Monetee",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF69480A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "⭐ Level $petLevel",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            "EXP: $petExp/100",
            style: const TextStyle(
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            "Happiness: ${happiness.round()}%",
            style: const TextStyle(
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 20),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: happiness / 100,
              minHeight: 20,
              backgroundColor:
                  const Color(0xFFE6E6E6),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(
                Color(0xFF04236F),
              ),
            ),
          ),
        ],
      ),
    );
  }
}