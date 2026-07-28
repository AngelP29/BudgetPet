const Expense = require("../models/Expense");
const Pet = require("../models/Pet");
const User = require("../models/User");

async function updatePetHappiness(userId, pet = null) {
    const user = await User.findById(userId);

    if (!pet) {
        pet = await Pet.findOne({ userId });
    }

    if (!user || !pet) {
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

    if (monthlyBudget <= 0) {
        pet.happiness = 100;
    } else {
        const percentUsed = totalSpent / monthlyBudget;

        if (percentUsed > 0.6) {
            pet.happiness = 30; 
        } else if (percentUsed >= 0.5) {
            pet.happiness = 50;
        } else if (percentUsed >= 0.1) {
            pet.happiness = 100;
        } else {
            pet.happiness = 0;
        }
    }

    await pet.save();

    return pet;
}

module.exports = { updatePetHappiness };