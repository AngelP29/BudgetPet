const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const swaggerUi = require('swagger-ui-express');
const swaggerJsdoc = require('swagger-jsdoc');
require('dotenv').config();

// Initialize application framework
const app = express();

// Middleware injections
app.use(express.json());
app.use(cors());

// Swagger Documentation Configuration
const swaggerOptions = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'BudgetPet / Monetee API Documentation',
      version: '1.0.0',
      description: 'Interactive API documentation for authentication, expenses, pets, and AI endpoints.',
    },
  },
  apis: ['./routes/*.js'], // Reads annotations inside your routes folder
};

const swaggerDocs = swaggerJsdoc(swaggerOptions);
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocs));

// REQUIRE ROUTE BLUEPRINTS
const authRoutes = require('./routes/auth');
const expenseRoutes = require('./routes/expenses');
const petRoutes = require('./routes/pets');
const aiRoutes = require('./routes/ai');
const dashboardRoutes = require('./routes/dashboard');

// MOUNT ENDPOINT LINKS TO APP
app.use('/api/auth', authRoutes);
app.use('/api/expenses', expenseRoutes);
app.use('/api/pets', petRoutes);
app.use('/api/chat', aiRoutes);
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
    app.listen(PORT, () => {
      console.log(`Backend server running locally on port ${PORT}`);
      console.log(`Swagger Documentation available at http://localhost:${PORT}/api-docs`);
    });
  })
  .catch(err => {
    console.error("Database connection error:", err);
  });