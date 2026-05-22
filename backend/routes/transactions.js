const express = require('express');
const router = express.Router();
const Transaction = require('../models/Transaction');
const User = require('../models/User');
const protect = require('../middleware/auth');

// GET /api/transactions
router.get('/', protect, async (req, res) => {
  try {
    const transactions = await Transaction.find({ userId: req.userId }).sort({ date: -1 });
    res.json({ success: true, transactions });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// POST /api/transactions/income
router.post('/income', protect, async (req, res) => {
  try {
    const { amount, label, merchant } = req.body;
    if (!amount || !label) {
      return res.status(400).json({ message: 'Amount and label required' });
    }
    const user = await User.findById(req.userId);
    user.balance = (user.balance || 0) + amount;
    await user.save();

    const tx = await Transaction.create({
      userId: req.userId,
      type: 'income',
      amount,
      label,
      merchant: merchant || '',
    });
    res.status(201).json({ success: true, transaction: tx, balance: user.balance });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
