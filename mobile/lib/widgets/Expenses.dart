import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Expenses extends StatefulWidget {
  const Expenses({
    super.key,
    required this.onExpenseChanged,
  });

  final VoidCallback onExpenseChanged;

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  final itemController = TextEditingController();
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();

  final editItemController = TextEditingController();
  final editAmountController = TextEditingController();
  final editDescriptionController = TextEditingController();

  List<Map<String, dynamic>> expenses = [];

  String errorMessage = "";
  String successMessage = "";

  bool isLoading = false;
  bool isFetchingExpenses = false;

  String? activeExpenseId;
  String? editingExpenseId;

  static const String baseUrl = "https://monetee.xyz";

  @override
  void initState() {
    super.initState();
    loadExpenses();
  }

  Future<String?> getUserId() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString("userId");
  }

  Future<void> loadExpenses() async {
    final userId = await getUserId();

    if (userId == null || userId.isEmpty) {
      if (!mounted) return;

      setState(() {
        errorMessage = "No logged-in user found.";
      });
      return;
    }

    try {
      setState(() {
        isFetchingExpenses = true;
        errorMessage = "";
      });

      final response = await http.get(
        Uri.parse("$baseUrl/api/expenses/$userId"),
      );

      final dynamic decodedBody = jsonDecode(response.body);

      if (response.statusCode != 200) {
        final data =
            decodedBody is Map<String, dynamic> ? decodedBody : {};

        if (!mounted) return;

        setState(() {
          errorMessage =
              data["error"]?.toString() ?? "Failed to load expenses.";
        });
        return;
      }

      final loadedExpenses = decodedBody is List
          ? decodedBody
              .whereType<Map>()
              .map((expense) => Map<String, dynamic>.from(expense))
              .toList()
          : <Map<String, dynamic>>[];

      if (!mounted) return;

      setState(() {
        expenses = loadedExpenses;
      });
    } on FormatException {
      if (!mounted) return;

      setState(() {
        errorMessage = "The server returned an invalid response.";
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage =
            "Unable to load expenses right now. Try again later.";
      });
    } finally {
      if (mounted) {
        setState(() {
          isFetchingExpenses = false;
        });
      }
    }
  }

  Future<void> addExpense() async {
    final userId = await getUserId();

    if (userId == null || userId.isEmpty) {
      setState(() {
        errorMessage = "No logged-in user found.";
      });
      return;
    }

    final item = itemController.text.trim();
    final amountText = amountController.text.trim();
    final description = descriptionController.text.trim();
    final amount = double.tryParse(amountText);

    setState(() {
      errorMessage = "";
      successMessage = "";
    });

    if (item.isEmpty || amountText.isEmpty) {
      setState(() {
        errorMessage = "Please fill in Item and Amount.";
      });
      return;
    }

    if (amount == null || amount <= 0) {
      setState(() {
        errorMessage = "Amount must be greater than 0.";
      });
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.post(
        Uri.parse("$baseUrl/api/expenses/add"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "userId": userId,
          "amount": amount,
          "category": item,
          "description": description,
        }),
      );

      final dynamic decodedBody = jsonDecode(response.body);
      final data =
          decodedBody is Map<String, dynamic> ? decodedBody : {};

      if (response.statusCode < 200 || response.statusCode >= 300) {
        if (!mounted) return;

        setState(() {
          errorMessage = data["error"]?.toString() ??
              "Failed to add expense. Try again soon.";
        });
        return;
      }

      itemController.clear();
      amountController.clear();
      descriptionController.clear();

      if (!mounted) return;

      setState(() {
        successMessage = "Expense added successfully!";
      });

      await loadExpenses();
      widget.onExpenseChanged();
    } on FormatException {
      if (!mounted) return;

      setState(() {
        errorMessage = "The server returned an invalid response.";
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = "Unable to add expense right now.";
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void startEditing(Map<String, dynamic> expense) {
    final expenseId = expense["_id"]?.toString();

    if (expenseId == null) return;

    setState(() {
      editingExpenseId = expenseId;
      activeExpenseId = expenseId;

      editItemController.text =
          expense["category"]?.toString() ?? "";

      editAmountController.text =
          _toDouble(expense["amount"]).toStringAsFixed(2);

      editDescriptionController.text =
          expense["description"]?.toString() ?? "";

      errorMessage = "";
      successMessage = "";
    });
  }

  void cancelEditing() {
    setState(() {
      activeExpenseId = null;
      editingExpenseId = null;
      errorMessage = "";
      successMessage = "";
    });

    editItemController.clear();
    editAmountController.clear();
    editDescriptionController.clear();
  }

  Future<void> saveEditedExpense(String expenseId) async {
    final userId = await getUserId();

    if (userId == null || userId.isEmpty) {
      setState(() {
        errorMessage = "No logged-in user found.";
      });
      return;
    }

    final item = editItemController.text.trim();
    final amountText = editAmountController.text.trim();
    final description = editDescriptionController.text.trim();
    final amount = double.tryParse(amountText);

    if (item.isEmpty || amountText.isEmpty) {
      setState(() {
        errorMessage = "Please fill in Item and Amount.";
      });
      return;
    }

    if (amount == null || amount <= 0) {
      setState(() {
        errorMessage = "Amount must be greater than 0.";
      });
      return;
    }

    try {
      setState(() {
        isLoading = true;
        errorMessage = "";
        successMessage = "";
      });

      final response = await http.put(
        Uri.parse("$baseUrl/api/expenses/$expenseId"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "userId": userId,
          "amount": amount,
          "category": item,
          "description": description,
        }),
      );

      final dynamic decodedBody = jsonDecode(response.body);
      final data =
          decodedBody is Map<String, dynamic> ? decodedBody : {};

      if (response.statusCode < 200 || response.statusCode >= 300) {
        if (!mounted) return;

        setState(() {
          errorMessage =
              data["error"]?.toString() ?? "Failed to update expense.";
        });
        return;
      }

      cancelEditing();

      if (!mounted) return;

      setState(() {
        successMessage = "Expense updated successfully!";
      });

      await loadExpenses();
      widget.onExpenseChanged();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = "Unable to update expense right now.";
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Expense"),
          content: const Text(
            "Are you sure you want to delete this expense?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE05252),
                foregroundColor: Colors.white,
              ),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final userId = await getUserId();

    if (userId == null || userId.isEmpty) {
      setState(() {
        errorMessage = "No logged-in user found.";
      });
      return;
    }

    try {
      setState(() {
        isLoading = true;
        errorMessage = "";
        successMessage = "";
      });

      final request = http.Request(
        "DELETE",
        Uri.parse("$baseUrl/api/expenses/$expenseId"),
      );

      request.headers["Content-Type"] = "application/json";
      request.body = jsonEncode({
        "userId": userId,
      });

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final dynamic decodedBody = jsonDecode(response.body);
      final data =
          decodedBody is Map<String, dynamic> ? decodedBody : {};

      if (response.statusCode < 200 || response.statusCode >= 300) {
        if (!mounted) return;

        setState(() {
          errorMessage =
              data["error"]?.toString() ?? "Failed to delete expense.";
        });
        return;
      }

      cancelEditing();

      if (!mounted) return;

      setState(() {
        successMessage = "Expense deleted successfully!";
      });

      await loadExpenses();
      widget.onExpenseChanged();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = "Unable to delete expense right now.";
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

  String formatDate(dynamic value) {
    if (value == null) return "";

    final date = DateTime.tryParse(value.toString());

    if (date == null) return "";

    return "${date.month}/${date.day}/${date.year}";
  }

  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
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

  Widget actionButton({
    required String label,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(label),
    );
  }

  Widget buildExpenseItem(Map<String, dynamic> expense) {
    final expenseId = expense["_id"]?.toString() ?? "";
    final isEditing = editingExpenseId == expenseId;
    final isActive = activeExpenseId == expenseId;

    if (isEditing) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
          ),
        ),
        child: Column(
          children: [
            TextField(
              controller: editItemController,
              decoration: inputDecoration("Item / Category"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: editAmountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: inputDecoration("Amount"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: editDescriptionController,
              decoration: inputDecoration("Description"),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                actionButton(
                  label: "Save Changes",
                  color: const Color(0xFF58C78D),
                  onPressed: isLoading
                      ? null
                      : () => saveEditedExpense(expenseId),
                ),
                actionButton(
                  label: "Cancel",
                  color: const Color(0xFF9CA3AF),
                  onPressed: cancelEditing,
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFEEEEEE),
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  expense["category"]?.toString() ?? "Expense",
                  style: const TextStyle(
                    color: Color(0xFF333333),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                "\$${_toDouble(expense["amount"]).toStringAsFixed(2)}",
                style: const TextStyle(
                  color: Color(0xFF4A7DF3),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  expense["description"]?.toString().trim().isNotEmpty == true
                      ? expense["description"].toString()
                      : "No description",
                  style: const TextStyle(
                    color: Color(0xFF777777),
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                formatDate(expense["date"]),
                style: const TextStyle(
                  color: Color(0xFF777777),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: isActive
                  ? [
                      actionButton(
                        label: "Edit",
                        color: const Color(0xFF58C78D),
                        onPressed: () => startEditing(expense),
                      ),
                      actionButton(
                        label: "Delete",
                        color: const Color(0xFFE05252),
                        onPressed: isLoading
                            ? null
                            : () => deleteExpense(expenseId),
                      ),
                      actionButton(
                        label: "Cancel",
                        color: const Color(0xFF9CA3AF),
                        onPressed: cancelEditing,
                      ),
                    ]
                  : [
                      actionButton(
                        label: "Manage",
                        color: const Color(0xFF53C9A8),
                        onPressed: () {
                          setState(() {
                            activeExpenseId = expenseId;
                            editingExpenseId = null;
                          });
                        },
                      ),
                    ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    itemController.dispose();
    amountController.dispose();
    descriptionController.dispose();

    editItemController.dispose();
    editAmountController.dispose();
    editDescriptionController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recentExpenses = expenses.take(5).toList();

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
                "Add Expense",
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
              const SizedBox(height: 18),
              TextField(
                controller: itemController,
                decoration: inputDecoration("Item / Category"),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: inputDecoration("Amount"),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: descriptionController,
                decoration: inputDecoration("Description"),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : addExpense,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF53C9A8),
                    foregroundColor: Colors.white,
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
                    isLoading ? "Adding..." : "Add Expense",
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Divider(
                color: Color(0xFFE5E7EB),
              ),
              const SizedBox(height: 8),
              const Text(
                "Recent Expenses",
                style: TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (isFetchingExpenses)
                const Text("Loading expenses...")
              else if (recentExpenses.isEmpty)
                const Text("No expenses logged yet.")
              else
                ...recentExpenses.map(buildExpenseItem),
            ],
          ),
        ),
      ),
    );
  }
}