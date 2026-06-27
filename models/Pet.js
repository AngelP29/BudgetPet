const mongoose = require('mongoose');

const PetSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true,
        unique: true // One pet per user account
    },
    name: {
        type: String,
        default: 'BudgetPet'
    },
    level: {
        type: Number,
        default: 1
    },
    exp: {
        type: Number,
        default: 0
    },
    happiness: {
        type: Number,
        default: 100
    },
    health: {
        type: Number,
        default: 100
    }
}, { timestamps: true });

module.exports = mongoose.model('Pet', PetSchema);