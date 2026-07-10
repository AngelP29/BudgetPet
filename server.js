const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

// Initialize application framework
const app = express();

// Middleware injections
app.use(express.json());
app.use(cors());

// REQUIRE ROUTE BLUEPRINTS
const authRoutes = require('./routes/auth');
const expenseRoutes = require('./routes/expenses');
const petRoutes = require('./routes/pets');
const aiRoutes = require('./routes/ai');
const dashboardRoutes = require('./routes/dashboard');

// MOUNT ENDPOINT LINKS TO APP
app.use('/api/pets', aiRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/expenses', expenseRoutes);
app.use('/api/pets', petRoutes);
app.use('/api/dashboard', dashboardRoutes);

// Base sanity check landing URL
app.get('/', (req, res) => {
    res.send("BudgetPet API Engine is live and listening... 🐾");
});

// Server boot-up connections
const PORT = process.env.PORT || 5000;
const uri = process.env.MONGODB_URI;

mongoose.connect(uri)
  .then(() => {
    console.log("MongoDB database connection established successfully! 🐱");
    app.listen(PORT, () => console.log(`Backend server running locally on port ${PORT}`));
  })
  .catch(err => {
    console.error("Database connection error:", err);
  });