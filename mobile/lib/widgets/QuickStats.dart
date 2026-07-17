import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class QuickStats extends StatefulWidget {
  const QuickStats({
    super.key,
    required this.refreshTrigger,
  });

  final int refreshTrigger;

  @override
  State<QuickStats> createState() => _QuickStatsState();
}

class _QuickStatsState extends State<QuickStats> {
  final monthlyBudgetController = TextEditingController();
  final monthlySavingsGoalController = TextEditingController();

  double totalSpent = 0;
  double budgetRemaining = 0;

  String errorMessage = "";
  String successMessage = "";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getQuickStats();
  }

  @override
  void didUpdateWidget(covariant QuickStats oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.refreshTrigger != widget.refreshTrigger) {
      getQuickStats();
    }
  }

  Future<String?> getUserId() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString("userId");
  }

  Future<void> getQuickStats() async {
    final userId = await getUserId();

    if (userId == null || userId.isEmpty) {
      if (!mounted) return;

      setState(() {
        errorMessage = "No logged-in user found.";
      });
      return;
    }

    try {
      if (mounted) {
        setState(() {
          isLoading = true;
          errorMessage = "";
          successMessage = "";
        });
      }

      final response = await http.get(
        Uri.parse("https://monetee.xyz/api/dashboard/$userId"),
      );

      final dynamic decodedBody = jsonDecode(response.body);
      final Map<String, dynamic> data =
          decodedBody is Map<String, dynamic> ? decodedBody : {};

      if (response.statusCode != 200) {
        if (!mounted) return;

        setState(() {
          errorMessage =
              data["error"]?.toString() ?? "Failed to load quick stats.";
        });
        return;
      }

      if (!mounted) return;

      setState(() {
        monthlyBudgetController.text =
            _toDouble(data["monthlyBudget"]).toStringAsFixed(2);

        monthlySavingsGoalController.text =
            _toDouble(data["monthlySavingsGoal"]).toStringAsFixed(2);

        totalSpent = _toDouble(data["totalSpent"]);
        budgetRemaining = _toDouble(data["budgetRemaining"]);
      });
    } on FormatException {
      if (!mounted) return;

      setState(() {
        errorMessage = "The server returned an invalid response.";
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = "Unable to load quick stats right now.";
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> updateGoals() async {
    final userId = await getUserId();

    if (userId == null || userId.isEmpty) {
      setState(() {
        errorMessage = "No logged-in user found.";
      });
      return;
    }

    final budgetText = monthlyBudgetController.text.trim();
    final savingsText = monthlySavingsGoalController.text.trim();

    setState(() {
      errorMessage = "";
      successMessage = "";
    });

    if (budgetText.isEmpty || savingsText.isEmpty) {
      setState(() {
        errorMessage = "Please enter both budget and savings goal.";
      });
      return;
    }

    final monthlyBudget = double.tryParse(budgetText);
    final monthlySavingsGoal = double.tryParse(savingsText);

    if (monthlyBudget == null || monthlySavingsGoal == null) {
      setState(() {
        errorMessage = "Please enter valid numbers.";
      });
      return;
    }

    if (monthlyBudget < 0 || monthlySavingsGoal < 0) {
      setState(() {
        errorMessage = "Budget and savings goal must be 0 or greater.";
      });
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.put(
        Uri.parse("http://192.241.249.164/api/dashboard/$userId"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "monthlyBudget": monthlyBudget,
          "monthlySavingsGoal": monthlySavingsGoal,
        }),
      );

      final dynamic decodedBody = jsonDecode(response.body);
      final Map<String, dynamic> data =
          decodedBody is Map<String, dynamic> ? decodedBody : {};

      if (response.statusCode != 200) {
        if (!mounted) return;

        setState(() {
          errorMessage =
              data["error"]?.toString() ?? "Failed to update goals.";
        });
        return;
      }

      if (!mounted) return;

      setState(() {
        successMessage = "Goals updated successfully!";
      });

      await getQuickStats();
    } on FormatException {
      if (!mounted) return;

      setState(() {
        errorMessage = "The server returned an invalid response.";
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = "Unable to update goals right now.";
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? "") ?? 0;
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      prefixText: "\$ ",
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

  Widget statBox({
    required String label,
    required double value,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            "\$${value.toStringAsFixed(2)}",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF4A7DF3),
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    monthlyBudgetController.dispose();
    monthlySavingsGoalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final monthlyBudget =
        double.tryParse(monthlyBudgetController.text) ?? 0;

    final monthlySavingsGoal =
        double.tryParse(monthlySavingsGoalController.text) ?? 0;

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
              const Text(
                "Quick Stats",
                style: TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              if (errorMessage.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  errorMessage,
                  style: const TextStyle(
                    color: Color(0xFFD64545),
                    fontSize: 14,
                  ),
                ),
              ],

              if (successMessage.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  successMessage,
                  style: const TextStyle(
                    color: Color(0xFF2E9C62),
                    fontSize: 14,
                  ),
                ),
              ],

              const SizedBox(height: 20),

              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.35,
                children: [
                  statBox(
                    label: "Monthly Budget",
                    value: monthlyBudget,
                  ),
                  statBox(
                    label: "Savings Goal",
                    value: monthlySavingsGoal,
                  ),
                  statBox(
                    label: "Spent This Month",
                    value: totalSpent,
                  ),
                  statBox(
                    label: "Budget Remaining",
                    value: budgetRemaining,
                  ),
                ],
              ),

              const SizedBox(height: 28),

              const Divider(
                color: Color(0xFFE5E7EB),
              ),

              const SizedBox(height: 24),

              const Text(
                "Update Goals",
                style: TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              TextField(
                controller: monthlyBudgetController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: _inputDecoration("Monthly Budget"),
              ),

              const SizedBox(height: 14),

              TextField(
                controller: monthlySavingsGoalController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: _inputDecoration("Monthly Savings Goal"),
              ),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : updateGoals,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF53C9A8),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        const Color(0xFF53C9A8).withOpacity(0.7),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Text(
                    isLoading ? "Saving..." : "Save Goals",
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