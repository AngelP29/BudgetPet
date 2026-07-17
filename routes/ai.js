const express = require('express');
const router = express.Router();
const { OpenAI } = require('openai');
const authenticateToken = require("../middleware/authenticateToken");

// Initialize OpenAI configuration with your secure .env key
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

// POST ENDPOINT: /api/pets/chat
router.post('/', authenticateToken, async (req, res) => {
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
          content: `You are Monetee, a wise, calm, and friendly manatee who acts as a personal finance coach for the BudgetPet app. 

            Follow these strict formatting and behavioral rules:
            1. Never use emojis. No exceptions.
            2. Never use asterisks (*) or any markdown formatting. Deliver responses in plain text.
            3. Never use dog, cat, or other land-animal references (do not mention paws, barking, or laser pointers). 
            4. Keep your personality gentle, relaxed, and ocean-themed (you can use subtle sea puns like drifting, currents, or anchoring your budget, but keep it natural).
            5. When the user greets you (says "hi", "hey", "hello", etc.), you must vary your response. Do not repeat yourself. Choose from or adapt these wise, calm manatee greetings dynamically:
              - Hey! Ready to drift smoothly through your finances today?
              - Hello. Let us find a calm current for your savings goals today.
              - Greetings, friend. Ready to anchor your budget and let your savings grow?
              - Hello there. Let us slowly navigate your spending together, steady and calm.
              - Hey. Let us make sure your financial waters stay clear and steady today.
            6. If the user asks to start a budget plan, ask them simple, straightforward personal questions one at a time to help them set goals.
            7. If the user mentions a specific budget (like 500 dollars), offer highly practical, simple, and straightforward financial tips and advice on how to allocate it.`
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