const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const Pet = require('../models/Pet');

// Secret key for signing web tokens (In production, move this to your .env)
const JWT_SECRET = process.env.JWT_SECRET;

if (!JWT_SECRET) {
    throw new Error("JWT_SECRET is not defined in the environment variables.");
}

const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z\d]).{8,}$/;

// 1. REGISTER ENDPOINT (/api/auth/register)
router.post('/register', async (req, res) => {
    try {
        const { firstName, lastName, username, email, password } = req.body;

        //basic validation
        if(!firstName || !lastName || !username || !email || !password){
            return res.status(400).json({error: "All fields are required."});
        }

        //password strength checker
        if (!passwordRegex.test(password)) {
            return res.status(400).json({
                error: "Password must be at least 8 characters and include uppercase, lowercase, a number, and a special character."
            });
        }

        //check duplicate email
        let existingEmail = await User.findOne({ email });
        if (existingEmail) {
            return res.status(400).json({ error: "User already registered with this email." });
        }

        //check duplicate username
        let existingUsername = await User.findOne({ username });
        if (existingUsername) {
            return res.status(400).json({ error: "That username is already taken." });
        }

        // Hash the password
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        // Save new user
        const user = new User({ firstName, lastName, username, email, password: hashedPassword });
        await user.save();

        // AUTOMATICALLY CREATE STARTER PET FOR THIS USER
        const starterPet = new Pet({
            userId: user._id,
            name: "BudgetPet"
        });
        await starterPet.save();

        // Create secure token for automatic login
        const token = jwt.sign({ userId: user._id }, JWT_SECRET, { expiresIn: '30d' });

        return res.status(201).json({ message: "Registration successful!", token, userId: user._id, username: user.username });
    } catch (err) {
        return res.status(500).json({ error: "Server error during registration: " + err.message });
    }
});

// 2. LOGIN ENDPOINT (/api/auth/login)
router.post('/login', async (req, res) => {
    try {
        const { username, password } = req.body;

        //basic validation
        if (!username || !password) {
            return res.status(400).json({ error: "Username and password are required." });
        }

        // Check user existence
        const user = await User.findOne({ username });
        if (!user) return res.status(400).json({ error: "Invalid credentials." });

        // Validate password
        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) return res.status(400).json({ error: "Invalid credentials." });

        // Issue new token (Keeps device logged in for 30 days)
        const token = jwt.sign({ userId: user._id }, JWT_SECRET, { expiresIn: '30d' });

        return res.json({ message: "Welcome back!", token, userId: user._id, username: user.username });
    } catch (err) {
        return res.status(500).json({ error: "Server error during login: " + err.message });
    }
});

module.exports = router;
