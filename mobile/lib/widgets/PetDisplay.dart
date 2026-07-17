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
      end: -12,
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
    final userId = preferences.getString("userId");

    if (userId == null || userId.isEmpty) {
      if (!mounted) {
        return;
      }

      setState(() {
        errorMessage = "No logged-in user found.";
      });

      return;
    }

    try {
      setState(() {
        isFetchingPet = true;
        errorMessage = "";
      });

      final response = await http.get(
        Uri.parse("https://monetee.xyz/api/pets/$userId"),
      );

      final dynamic decodedBody = jsonDecode(response.body);

      final Map<String, dynamic> data =
          decodedBody is Map<String, dynamic>
              ? decodedBody
              : <String, dynamic>{};

      if (response.statusCode != 200) {
        if (!mounted) {
          return;
        }

        setState(() {
          errorMessage =
              data["error"]?.toString() ??
              "Failed to load pet information.";
        });

        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        pet = data;
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
        errorMessage = "Unable to retrieve pet information.";
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

    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? "") ?? 1;
  }

  int get petExp {
    final value = pet?["exp"];

    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? "") ?? 0;
  }

  double get petHappiness {
    final value = pet?["happiness"];

    if (value is num) {
      return value.toDouble().clamp(0, 100);
    }

    return double.tryParse(
          value?.toString() ?? "",
        )?.clamp(0, 100) ??
        100;
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
      padding: const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 22,
      ),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A5A78).withOpacity(0.18),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
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
              style: TextStyle(
                color: Color(0xFF666666),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 15),
          ],

          AnimatedBuilder(
            animation: _floatAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatAnimation.value),
                child: child,
              );
            },
            child: Image.asset(
              "assets/images/Monetee.png",
              width: 250,
              height: 250,
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            "Monetee",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF333333),
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
              color: const Color(0xFF4FD3D9),
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
              backgroundColor: const Color(0xFFE6E6E6),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF58C78D),
              ),
            ),
          ),
        ],
      ),
    );
  }
}