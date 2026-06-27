const express = require('express');
const router = express.Router();
const { OpenAI } = require('openai');

// Initialize OpenAI configuration with your secure .env key
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

// POST ENDPOINT: /api/pets/chat
router.post('/chat', async (req, res) => {
  try {
    const { message, petName } = req.body;

    if (!message) {
      return res.status(400).json({ error: "Message content is required." });
    }

    // Call the OpenAI Chat Completions API
    const response = await openai.chat.completions.create({
      model: "gpt-4o-mini", // Cost-effective, fast, perfect for a school MVP project
      messages: [
        {
          role: "system",
          content: `You are ${petName || 'BudgetPet'}, a cute, encouraging, and witty digital pet avatar inside a financial tracking app. Your job is to act as a supportive financial coach. Give short, engaging, and motivating budgeting advice. Use occasional pet emojis (🐾, 🐱, 🐶, 🪙). Do not give complex corporate financial advice—keep it accessible, friendly, and geared towards saving money and building healthy habits.`
        },
        {
          role: "user",
          content: message
        }
      ],
      max_tokens: 150 // Keeps responses concise and fast
    });

    // Extract the AI's response text
    const aiReply = response.choices[0].message.content;
    res.json({ reply: aiReply });

  } catch (err) {
    res.status(500).json({ error: "AI Assistant failed to respond: " + err.message });
  }
});

module.exports = router;