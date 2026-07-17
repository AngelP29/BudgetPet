import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'LoginScreen.dart';
import '../widgets/PetDisplay.dart';
import '../widgets/QuickStats.dart';
import '../widgets/PetChat.dart';
import '../widgets/Expenses.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String username = "User";
  bool isLoadingUser = true;

  int refreshDashboard = 0;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  void refreshDashboardData() {
    setState(() {
      refreshDashboard++;
    });
  }

  Future<void> loadUser() async {
    final preferences = await SharedPreferences.getInstance();

    if (!mounted) {
      return;
    }

    setState(() {
      username = preferences.getString("username") ?? "User";
      isLoadingUser = false;
    });
  }

  Future<void> handleLogout() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove("userId");
    await preferences.remove("token");
    await preferences.remove("username");

    if (!mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  Widget _logo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          "assets/images/MoneteeLogo.png",
          width: 125,
          height: 125,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 10),
        const Text(
          "BudgetPet",
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _profileButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        "$username 👤",
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF333333),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _logoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: handleLogout,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4A7DF3),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          elevation: 6,
          shadowColor: Colors.black.withOpacity(0.12),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        child: const Text("Logout"),
      ),
    );
  }

  Widget _buildHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth <= 900;

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: _logo(),
              ),
              const SizedBox(height: 20),
              _profileButton(),
              const SizedBox(height: 12),
              _logoutButton(),
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _logo(),
            Row(
              children: [
                SizedBox(
                  width: 150,
                  child: _profileButton(),
                ),
                const SizedBox(width: 14),
                SizedBox(
                  width: 110,
                  child: _logoutButton(),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsAndChat() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useColumns = constraints.maxWidth > 900;

        final quickStats = QuickStats(
          refreshTrigger: refreshDashboard,
        );

        const petChat = PetChat();

        if (useColumns) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: quickStats),
              const SizedBox(width: 30),
              const Expanded(child: petChat),
            ],
          );
        }

        return Column(
          children: [
            quickStats,
            const SizedBox(height: 30),
            petChat,
          ],
        );
      },
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 1100,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),

                      const SizedBox(height: 35),

                      Center(

                        child: Text(
                          isLoadingUser
                              ? "Welcome back!"
                              : "Welcome back, $username!",
                          textAlign: TextAlign.center,   
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      PetDisplay(
                        refreshTrigger: refreshDashboard,
                      ),

                      const SizedBox(height: 30),

                      _buildStatsAndChat(),

                      const SizedBox(height: 30),

                      Expenses(
                        onExpenseChanged: refreshDashboardData,
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}