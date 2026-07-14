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

  void refreshDashboardData() {
    setState(() {
        refreshDashboard++;
    });
  }

  @override
  void initState() {
    super.initState();
    loadUser();
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

  Widget dashboardCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
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
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF333333),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  Widget placeholderContent(String text, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Icon(
              icon,
              size: 52,
              color: const Color(0xFF56CEC0),
            ),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF777777),
                fontSize: 16,
              ),
            ),
          ],
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
                      // Header
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isNarrow = constraints.maxWidth < 650;

                          if (isNarrow) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "🐾",
                                      style: TextStyle(fontSize: 28),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "BudgetPet",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
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
                              const Row(
                                children: [
                                  Text(
                                    "🐾",
                                    style: TextStyle(fontSize: 28),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "BudgetPet",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  _profileButton(),
                                  const SizedBox(width: 14),
                                  _logoutButton(),
                                ],
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 35),

                      Text(
                        isLoadingUser
                            ? "Welcome back!"
                            : "Welcome back, $username!",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Pet Home
                      PetDisplay(
                        refreshTrigger: refreshDashboard,
                      ),

                      const SizedBox(height: 30),

                      // Responsive stats and chat section
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final useColumns = constraints.maxWidth >= 850;

                          final quickStats = QuickStats(
                            refreshTrigger: refreshDashboard,
                          );

                

                          final petChat = const PetChat();

                          if (useColumns) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: quickStats),
                                const SizedBox(width: 30),
                                Expanded(child: petChat),
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
                      ),

                      const SizedBox(height: 30),

                      // Expenses
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

  Widget _profileButton() {
    return Container(
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
    return ElevatedButton(
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
    );
  }
}