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
  double monthlyBudget = 0;
  double monthlySavingsGoal = 0;

  String errorMessage = "";
  String successMessage = "";

  bool isFetchingStats = false;
  bool isSavingGoals = false;

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
      if (!mounted) {
        return;
      }

      setState(() {
        errorMessage = "No logged-in user found.";
      });

      return;
    }

    try {
      if (mounted) {
        setState(() {
          isFetchingStats = true;
          errorMessage = "";
        });
      }

      final response = await http.get(
        Uri.parse("https://monetee.xyz/api/dashboard/$userId"),
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
              "Failed to load quick stats.";
        });

        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        monthlyBudget = _toDouble(data["monthlyBudget"]);

        monthlySavingsGoal = _toDouble(data["monthlySavingsGoal"]);

        totalSpent = _toDouble(data["totalSpent"]);
        budgetRemaining = _toDouble(data["budgetRemaining"]);
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
        errorMessage = "Unable to load quick stats right now.";
      });
    } finally {
      if (mounted) {
        setState(() {
          isFetchingStats = false;
        });
      }
    }
  }

  Future<void> updateGoals() async {
    final userId = await getUserId();

    if (userId == null || userId.isEmpty) {
      if (!mounted) {
        return;
      }

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
        errorMessage =
            "Budget and savings goal must be 0 or greater.";
      });

      return;
    }

    try {
      setState(() {
        isSavingGoals = true;
      });

      final response = await http.put(
        Uri.parse("https://monetee.xyz/api/dashboard/$userId"),
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
              "Failed to update goals.";
        });

        return;
      }

      await getQuickStats();

      if (!mounted) {
        return;
      }

      setState(() {
        successMessage = "Goals updated successfully!";

        monthlyBudgetController.clear();
        monthlySavingsGoalController.clear();
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
        errorMessage = "Unable to update goals right now.";
      });
    } finally {
      if (mounted) {
        setState(() {
          isSavingGoals = false;
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFD64545),
          width: 2,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFD64545),
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
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "\$${value.toStringAsFixed(2)}",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF4A7DF3),
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF666666),
              fontSize: 14,
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
                  "Quick Stats",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
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

              if (isFetchingStats) ...[
                const SizedBox(height: 18),
                const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF53C9A8),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              LayoutBuilder(
                builder: (context, constraints) {
                  final cardWidth =
                      (constraints.maxWidth - 20) / 2;

                  return Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      SizedBox(
                        width: cardWidth,
                        child: statBox(
                          label: "Monthly Budget",
                          value: monthlyBudget,
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: statBox(
                          label: "Savings Goal",
                          value: monthlySavingsGoal,
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: statBox(
                          label: "Spent This Month",
                          value: totalSpent,
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: statBox(
                          label: "Budget Remaining",
                          value: budgetRemaining,
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 28),

              const Divider(
                color: Color(0xFFE5E7EB),
              ),

              const SizedBox(height: 24),

              Center(

                child:Text(
                  "Update Goals",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
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
                decoration:
                    _inputDecoration("Monthly Savings Goal"),
              ),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      isSavingGoals ? null : updateGoals,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF53C9A8),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        const Color(0xFF53C9A8).withOpacity(0.7),
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Text(
                    isSavingGoals
                        ? "Saving..."
                        : "Save Goals",
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

