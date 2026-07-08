const express = require('express');
const router = express.Router();
const Expense = require('../models/Expense');
const Pet = require('../models/Pet');

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
        const pet = await Pet.findOne({ userId });
        if (pet) {
            pet.happiness = Math.max(0, pet.happiness - 5); // Subtract 5 points, minimum 0
            await pet.save();
        }

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

module.exports = router;