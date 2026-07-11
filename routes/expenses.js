const express = require('express');
const router = express.Router();
const Expense = require('../models/Expense');
const Pet = require('../models/Pet');
const User = require('../models/User');

async function updatePetHappiness(userId){
    const user = await User.findById(userId);
    const pet = await Pet.findOne({ userId });

    if(!user || !pet){
        return;
    }

    const now = new Date();
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
    const startOfNextMonth = new Date(now.getFullYear(), now.getMonth() + 1, 1);

    const expenses = await Expense.find({
        userId,
        date: {
            $gte: startOfMonth,
            $lt: startOfNextMonth
        }
    });

    const totalSpent = expenses.reduce(
        (sum, expense) => sum + Number(expense.amount || 0),
        0
    );

    const monthlyBudget = user.monthlyBudget || 0;

    if(monthlyBudget <= 0){
        pet.happiness = 100;
    } else {
        const percentUsed = totalSpent / monthlyBudget;

        if (percentUsed <= 0.50) {
            pet.happiness = 100;
        } else if (percentUsed <= 0.75) {
            pet.happiness = 85;
        } else if (percentUsed <= 0.90) {
            pet.happiness = 70;
        } else if (percentUsed <= 1.00) {
            pet.happiness = 50;
        } else {
            pet.happiness = 25;
        }
    }

    await pet.save();

    return pet;
}

// 1. ADD NEW EXPENSE (/api/expenses/add)
router.post('/add', async (req, res) => {
    try {
        const { userId, amount, category, description } = req.body;

        if (!userId || !amount || !category) {
            return res.status(400).json({ error: "User, amount, and category are required." });
        }

        if (Number(amount) <= 0) {
            return res.status(400).json({ error: "Amount must be greater than 0." });
        }

        const newExpense = new Expense({ userId, amount, category, description });
        await newExpense.save();

        // GAMIFICATION STEP: Fetch user's pet and drop happiness slightly
        const pet = await updatePetHappiness(userId);

        res.status(201).json({ message: "Expense logged!", expense: newExpense, currentPetHappiness: pet ? pet.happiness : 100 });
    } catch (err) {
        res.status(500).json({ error: "Failed to add expense: " + err.message });
    }
});

// 2. GET ALL EXPENSES FOR A SPECIFIC USER (/api/expenses/:userId)
router.get('/:userId', async (req, res) => {
    try {
        const expenses = await Expense.find({ userId: req.params.userId }).sort({ date: -1 });
        res.json(expenses);
    } catch (err) {
        res.status(500).json({ error: "Failed to load expenses: " + err.message });
    }
});

//update logged expense
router.put('/:expenseId', async (req, res) => {
    try{
        const { userId, amount, category, description } = req.body;
        const { expenseId } = req.params;

        if (!userId || !amount || !category) {
            return res.status(400).json({ error: "User, amount, and category are required." });
        }

        if (Number(amount) <= 0) {
            return res.status(400).json({ error: "Amount must be greater than 0." });
        }

        const expense = await Expense.findOne({ _id: expenseId, userId });

        if (!expense) {
            return res.status(404).json({ error: "Expense not found." });
        }

        expense.amount = Number(amount);
        expense.category = category;
        expense.description = description || "";

        await expense.save();

        const pet = await updatePetHappiness(userId);

        return res.json({
            message: "Expense updated successfully!",
            expense,
            currentPetHappiness: pet ? pet.happiness : 100
        });
    } catch(err){
        res.status(500).json({ error: "Failed to modify expense: " + err.message });
    }
});

//delete logged expense
router.delete('/:expenseId', async (req, res) => {
    try{
        const { userId } = req.body;
        const { expenseId } = req.params;

        if (!userId) {
            return res.status(400).json({ error: "User ID is required." });
        }

        const deletedExpense = await Expense.findOneAndDelete({ _id: expenseId, userId });

        if (!deletedExpense) {
            return res.status(404).json({ error: "Expense not found." });
        }

        const pet = await updatePetHappiness(userId);

        return res.json({ 
            message: "Expense deleted successfully!",
            currentPetHappiness: pet ? pet.happiness : 100
         });
    } catch(err){
        res.status(500).json({ error: "Failed to delete expense: " + err.message });
    }
});

module.exports = router;