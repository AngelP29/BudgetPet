const express = require('express');
const router = express.Router();
const Pet = require('../models/Pet');
const authenticateToken = require("../middleware/authenticateToken");

// 1. GET USER'S PET DETAILS FOR DASHBOARD GRAPHICS (/api/pets)
router.get('/', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.userId;
        const pet = await Pet.findOne({ userId });
        if (!pet) return res.status(404).json({ error: "Pet records not found." });
        res.json(pet);
    } catch (err) {
        res.status(500).json({ error: "Failed to fetch pet metrics: " + err.message });
    }
});

// 2. INTERACT/FEED PET TO INCREASE STATUS (/api/pets/interact)
router.post('/interact', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.userId;
        const { action } = req.body; // action could be 'feed' or 'play'
        const pet = await Pet.findOne({ userId });
        if (!pet) return res.status(404).json({ error: "Pet not found." });

        if (action === 'feed') {
            pet.health = Math.min(100, pet.health + 10);
            pet.exp += 15;
        } else if (action === 'play') {
            pet.happiness = Math.min(100, pet.happiness + 15);
            pet.exp += 10;
        }

        // Handle leveling up mechanics (Every 100 EXP points = 1 Level Up!)
        if (pet.exp >= 100) {
            pet.level += 1;
            pet.exp = pet.exp - 100;
        }

        await pet.save();
        res.json({ message: `Action '${action}' complete!`, pet });
    } catch (err) {
        res.status(500).json({ error: "Interaction error: " + err.message });
    }
});

module.exports = router;