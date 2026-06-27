const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const Pet = require('../models/Pet');

// Secret key for signing web tokens (In production, move this to your .env)
const JWT_SECRET = "budgetpet_super_secret_key_12345";

// 1. REGISTER ENDPOINT (/api/auth/register)
router.post('/register', async (req, res) => {
    try {
        const { firstName, lastName, email, password } = req.body;

        // Check if user already exists
        let user = await User.findOne({ email });
        if (user) return res.status(400).json({ error: "User already registered with this email." });

        // Hash the password
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        // Save new user
        user = new User({ firstName, lastName, email, password: hashedPassword });
        await user.save();

        // AUTOMATICALLY CREATE STARTER PET FOR THIS USER
        const starterPet = new Pet({
            userId: user._id,
            name: "BudgetPet"
        });
        await starterPet.save();

        // Create secure token for automatic login
        const token = jwt.sign({ userId: user._id }, JWT_SECRET, { expiresIn: '30d' });

        res.status(201).json({ message: "Registration successful!", token, userId: user._id });
    } catch (err) {
        res.status(500).json({ error: "Server error during registration: " + err.message });
    }
});

// 2. LOGIN ENDPOINT (/api/auth/login)
router.post('/login', async (req, res) => {
    try {
        const { email, password } = req.body;

        // Check user existence
        const user = await User.findOne({ email });
        if (!user) return res.status(400).json({ error: "Invalid credentials." });

        // Validate password
        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) return res.status(400).json({ error: "Invalid credentials." });

        // Issue new token (Keeps device logged in for 30 days)
        const token = jwt.sign({ userId: user._id }, JWT_SECRET, { expiresIn: '30d' });

        res.json({ message: "Welcome back!", token, userId: user._id });
    } catch (err) {
        res.status(500).json({ error: "Server error during login: " + err.message });
    }
});

module.exports = router;