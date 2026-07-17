const express = require('express');
const authenticateToken = require("../middleware/authenticateToken");
const router = express.Router();
const Expense = require('../models/Expense');
const Pet = require('../models/Pet');
const User = require('../models/User');

async function updatePetHappiness(userId, pet = null){
    const user = await User.findById(userId);
    
    if(!pet){
        pet = await Pet.findOne({ userId });
    }

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

async function awardPetExp(userId, expChange){
    const pet = await Pet.findOne({ userId });

    if(!pet){
        return null;
    }

    pet.exp = Math.max(0, pet.exp + expChange);

    while(pet.exp >= 100){
        pet.level += 1;
        pet.exp -= 100;
    }

    await pet.save();

    return pet;
}

async function calculateExpenseExp(userId){
    const user = await User.findById(userId);

    if(!user){
        return 0;
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
        return 2;
    }

    const percentUsed = totalSpent / monthlyBudget;

    if(percentUsed <= 0.50){
        return 10;
    }
    else if(percentUsed <= 0.75){
        return 7;
    }
    else if(percentUsed <= 0.90){
        return 4;
    }
    else if(percentUsed <= 1.00){
        return 2;
    }

    return 0;
}

//add new expense (/api/expenses/add)
router.post('/add', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.userId;
        const { amount, category, description } = req.body;

        if (!amount || !category) {
            return res.status(400).json({ error: "Amount and category are required." });
        }

        if (Number(amount) <= 0) {
            return res.status(400).json({ error: "Amount must be greater than 0." });
        }

        const newExpense = new Expense({ userId, amount, category, description });
        await newExpense.save();

        const expEarned = await calculateExpenseExp(userId);

        const updatedPet = await awardPetExp(userId, expEarned);

        const finalPet = await updatePetHappiness(userId, updatedPet);

        return res.status(201).json({
            message: "Expense logged!",
            expense: newExpense,
            currentPetHappiness: finalPet ? finalPet.happiness : 100,
            currentPetLevel: finalPet ? finalPet.level : 1,
            currentPetExp: finalPet ? finalPet.exp : 0
        });    
    } catch (err) {
        res.status(500).json({ error: "Failed to add expense: " + err.message });
    }
});

//load expense(s) (/api/expenses/:userId)
router.get('/', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.userId;
        const expenses = await Expense.find({ userId }).sort({ date: -1 });
        res.json(expenses);
    } catch (err) {
        res.status(500).json({ error: "Failed to load expenses: " + err.message });
    }
});

//update logged expense
router.put('/:expenseId', authenticateToken, async (req, res) => {
    try{
        const userId = req.user.userId;
        const { amount, category, description } = req.body;
        const { expenseId } = req.params;

        if (!amount || !category) {
            return res.status(400).json({ error: "Amount, and category are required." });
        }

        if (Number(amount) <= 0) {
            return res.status(400).json({ error: "Amount must be greater than 0." });
        }

        const expense = await Expense.findOne({ _id: expenseId, userId });

        if (!expense) {
            return res.status(404).json({ error: "Expense not found." });
        }

        const oldAmount = expense.amount;

        expense.amount = Number(amount);
        expense.category = category;
        expense.description = description || "";

        await expense.save();

        let expChange = 0;

        const difference = oldAmount - Number(amount);

        if(difference >= 20){
            expChange = 5;
        }
        else if(difference >= 10){
            expChange = 3;
        }
        else if(difference > 0){
            expChange = 1;
        }
        else if(difference <= -20){
            expChange = -5;
        }
        else if(difference <= -10){
            expChange = -3;
        }
        else if(difference < 0){
            expChange = -1;
        }

        const updatedPet = await awardPetExp(userId, expChange);

        const finalPet = await updatePetHappiness(userId, updatedPet);

        return res.json({
            message: "Expense updated successfully!",
            expense,
            currentPetHappiness: finalPet ? finalPet.happiness : 100,
            currentPetLevel: finalPet ? finalPet.level : 1,
            currentPetExp: finalPet ? finalPet.exp : 0
        });
    } catch(err){
        res.status(500).json({ error: "Failed to modify expense: " + err.message });
    }
});

//delete logged expense
router.delete('/:expenseId', authenticateToken, async (req, res) => {
    try{
        const userId = req.user.userId;
        const { expenseId } = req.params;

        const deletedExpense = await Expense.findOneAndDelete({ _id: expenseId, userId });

        if (!deletedExpense) {
            return res.status(404).json({ error: "Expense not found." });
        }

        const updatedPet = await awardPetExp(userId, -2);

        const finalPet = await updatePetHappiness(userId, updatedPet);

        return res.json({ 
            message: "Expense deleted successfully!",
            currentPetHappiness: finalPet ? finalPet.happiness : 100,
            currentPetLevel: finalPet ? finalPet.level : 1,
            currentPetExp: finalPet ? finalPet.exp : 0
         });
    } catch(err){
        res.status(500).json({ error: "Failed to delete expense: " + err.message });
    }
});

module.exports = router;