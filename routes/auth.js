const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const crypto = require("crypto");

const User = require('../models/User');
const Pet = require('../models/Pet');
const { sendVerificationEmail } = require("../utils/email");
const { resetPasswordRequest } = require("../utils/resetPassword");

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
        if (!firstName || !lastName || !username || !email || !password) {
            return res.status(400).json({ error: "All fields are required." });
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

        const verificationToken = crypto.randomBytes(32).toString("hex");
        const verificationTokenExpires = new Date(
            Date.now() + 24 * 60 * 60 * 1000
        );

        // Save new user
        const user = new User({
            firstName,
            lastName,
            username,
            email,
            password: hashedPassword,
            isVerified: false,
            verificationToken,
            verificationTokenExpires
        });
        await user.save();

        // AUTOMATICALLY CREATE STARTER PET FOR THIS USER
        const starterPet = new Pet({
            userId: user._id,
            name: "BudgetPet"
        });
        await starterPet.save();

        //all auth knows about emails
        await sendVerificationEmail(
            user.email,
            verificationToken
        );

        // Create secure token for automatic login
        return res.status(201).json({
            message: "Registration successful. Please verify your email."
        });

    } catch (err) {
        return res.status(500).json({ error: "Server error during registration: " + err.message });
    }
});

//resend verification email route
router.post("/resend-verification", async (req, res) => {
    try {
        const { email } = req.body;

        if (!email) {
            return res.status(400).json({
                error: "Email is required."
            });
        }

        const user = await User.findOne({ email });

        if (!user) {
            return res.status(404).json({
                error: "User not found."
            });
        }

        if (user.isVerified) {
            return res.status(400).json({
                error: "This account is already verified."
            });
        }

        const verificationToken =
            crypto.randomBytes(32).toString("hex");

        const verificationTokenExpires =
            new Date(Date.now() + 24 * 60 * 60 * 1000);

        user.verificationToken = verificationToken;
        user.verificationTokenExpires = verificationTokenExpires;

        await user.save();

        await sendVerificationEmail(
            user.email,
            verificationToken
        );

        return res.json({
            message: "Verification email sent."
        });
    } catch (err) {
        return res.status(500).json({
            error: err.message
        });
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

        if (!user) {
            return res.status(400).json({
                error: "Invalid credentials."
            });
        }

        if (!user.isVerified) {
            return res.status(403).json({
                error: "Please verify your email before logging in."
            });
        }

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

//verification route for signups
router.get("/verify", async (req, res) => {
    try {
        const { token } = req.query;

        if (!token) {
            return res.status(400).json({
                error: "Missing verification token."
            });
        }

        const user = await User.findOne({
            verificationToken: token
        });

        if (!user) {
            return res.status(400).json({
                error: "Invalid verification link."
            });
        }

        if (user.verificationTokenExpires < new Date()) {
            return res.status(400).json({
                error: "Verification link has expired."
            });
        }

        user.isVerified = true;
        user.verificationToken = "";
        user.verificationTokenExpires = null;

        await user.save();

        return res.redirect(
            `${process.env.FRONTEND_URL}/verify`
        );
    } catch (err) {
        return res.status(500).json({
            error: err.message
        });
    }
});

// Request from pop-up
router.post('/requestReset', async (req, res) => {
    const { email } = req.body;
    try {
        if (!email) {
            return res.status(400).json({
                error: "Email is required."
            });
        }

        const user = await User.findOne({ email });

        if (user) {

            const verificationToken =
                crypto.randomBytes(32).toString("hex");

            const verificationTokenExpires =
                new Date(Date.now() + 24 * 60 * 60 * 1000);

            user.verificationToken = verificationToken;
            user.verificationTokenExpires = verificationTokenExpires;

            await user.save();

            await resetPasswordRequest(
                user.email,
                verificationToken
            );
        }

        return res.status(200).json({
            status: "success",
            message: "Password email sent"
        });
    }
    catch (err) {
        return res.status(500).json({
            error: err.message
        });
    }
});
// Request post-email update password
router.post('/updatePass', async (req, res) => {

    const { token, password } = req.body;

    try {

        if (!token) {
            return res.status(400).json({
                error: "Missing token."
            });
        }

        const user = await User.findOne({
            verificationToken: token
        });

        if (!user) {
            return res.status(400).json({
                error: "Invalid reset password token."
            });
        }

        if (user.verificationTokenExpires < new Date()) {
            return res.status(400).json({
                error: "Request token has expired."
            });
        }

        // Hash the password
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        user.password = hashedPassword;

        await user.save;

        return res.json({
            message: "Password reset successfuly."
        });
    }
    catch (err) {
        return res.status(500).json({
            error: err.message
        });
    }

});

module.exports = router;
