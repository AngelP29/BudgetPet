const express = require('express');
const router = express.Router();
const User = require('../models/User');
const Expense = require('../models/Expense');

// GET quick stats for one user
router.get('/:userId', async (req, res) => {
    try {
        const { userId } = req.params;

        const user = await User.findById(userId);

        if (!user) {
            return res.status(404).json({ error: "User not found." });
        }

        // current month range
        const now = new Date();
        const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
        const startOfNextMonth = new Date(now.getFullYear(), now.getMonth() + 1, 1);

        // only expenses from this month
        const expenses = await Expense.find({
            userId,
            date: {
                $gte: startOfMonth,
                $lt: startOfNextMonth
            }
        });

        const totalSpent = expenses.reduce((sum, expense) => {
            return sum + Number(expense.amount || 0);
        }, 0);

        const monthlyBudget = user.monthlyBudget || 0;
        const monthlySavingsGoal = user.monthlySavingsGoal || 0;
        const budgetRemaining = monthlyBudget - totalSpent;

        return res.json({
            monthlyBudget,
            monthlySavingsGoal,
            totalSpent,
            budgetRemaining
        });

    } catch (err) {
        return res.status(500).json({
            error: "Failed to load quick stats: " + err.message
        });
    }
});

// UPDATE monthly budget + savings goal
router.put('/:userId', async (req, res) => {
    try {
        const { userId } = req.params;
        const { monthlyBudget, monthlySavingsGoal } = req.body;

        if (monthlyBudget === undefined || monthlySavingsGoal === undefined) {
            return res.status(400).json({
                error: "Monthly budget and savings goal are required."
            });
        }

        if (Number(monthlyBudget) < 0 || Number(monthlySavingsGoal) < 0) {
            return res.status(400).json({
                error: "Values must be 0 or greater."
            });
        }

        const updatedUser = await User.findByIdAndUpdate(
            userId,
            {
                monthlyBudget: Number(monthlyBudget),
                monthlySavingsGoal: Number(monthlySavingsGoal)
            },
            { new: true }
        );

        if (!updatedUser) {
            return res.status(404).json({ error: "User not found." });
        }

        return res.json({
            message: "Goals updated successfully!",
            monthlyBudget: updatedUser.monthlyBudget,
            monthlySavingsGoal: updatedUser.monthlySavingsGoal
        });

    } catch (err) {
        return res.status(500).json({
            error: "Failed to update goals: " + err.message
        });
    }
});

module.exports = router;