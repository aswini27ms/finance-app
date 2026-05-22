const express = require('express');
const router = express.Router();
const Expense = require('../models/Expense');
const Folder = require('../models/Folder');
const protect = require('../middleware/auth');

// @route   GET /api/expenses
// @desc    Get all expenses for a user
// @access  Private
router.get('/', protect, async (req, res) => {
  try {
    const expenses = await Expense.find({ userId: req.userId })
      .sort({ date: -1 })
      .populate('folderId', 'name');
    res.status(200).json({ success: true, expenses });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   GET /api/expenses/folder/:folderId
// @desc    Get expenses for a specific folder
// @access  Private
router.get('/folder/:folderId', protect, async (req, res) => {
  try {
    const folder = await Folder.findById(req.params.folderId);
    if (!folder || folder.userId.toString() !== req.userId) {
      return res.status(403).json({ message: 'Not authorized' });
    }

    const expenses = await Expense.find({ folderId: req.params.folderId })
      .sort({ date: -1 });
    res.status(200).json({ success: true, expenses });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   GET /api/expenses/:id
// @desc    Get single expense
// @access  Private
router.get('/:id', protect, async (req, res) => {
  try {
    const expense = await Expense.findById(req.params.id);
    if (!expense) {
      return res.status(404).json({ message: 'Expense not found' });
    }
    if (expense.userId.toString() !== req.userId) {
      return res.status(403).json({ message: 'Not authorized' });
    }
    res.status(200).json({ success: true, expense });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   POST /api/expenses
// @desc    Create a new expense
// @access  Private
router.post('/', protect, async (req, res) => {
  try {
    const { folderId, amount, label, description, category, date } = req.body;

    if (!folderId || !amount || !label) {
      return res.status(400).json({ message: 'Please provide all required fields' });
    }

    // Verify folder belongs to user
    const folder = await Folder.findById(folderId);
    if (!folder || folder.userId.toString() !== req.userId) {
      return res.status(403).json({ message: 'Not authorized' });
    }

    const expense = new Expense({
      userId: req.userId,
      folderId,
      amount,
      label,
      description,
      category,
      date: date || Date.now()
    });

    await expense.save();

    // Update folder spent amount
    folder.spent += amount;
    await folder.save();

    res.status(201).json({ success: true, expense });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   PUT /api/expenses/:id
// @desc    Update an expense
// @access  Private
router.put('/:id', protect, async (req, res) => {
  try {
    let expense = await Expense.findById(req.params.id);
    if (!expense) {
      return res.status(404).json({ message: 'Expense not found' });
    }
    if (expense.userId.toString() !== req.userId) {
      return res.status(403).json({ message: 'Not authorized' });
    }

    const { amount, label, description, category, date } = req.body;

    // If amount changed, update folder spent
    if (amount && amount !== expense.amount) {
      const folder = await Folder.findById(expense.folderId);
      const difference = amount - expense.amount;
      folder.spent += difference;
      await folder.save();
    }

    expense = await Expense.findByIdAndUpdate(
      req.params.id,
      { amount, label, description, category, date },
      { new: true, runValidators: true }
    );

    res.status(200).json({ success: true, expense });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   DELETE /api/expenses/:id
// @desc    Delete an expense
// @access  Private
router.delete('/:id', protect, async (req, res) => {
  try {
    const expense = await Expense.findById(req.params.id);
    if (!expense) {
      return res.status(404).json({ message: 'Expense not found' });
    }
    if (expense.userId.toString() !== req.userId) {
      return res.status(403).json({ message: 'Not authorized' });
    }

    // Update folder spent
    const folder = await Folder.findById(expense.folderId);
    folder.spent -= expense.amount;
    await folder.save();

    await Expense.findByIdAndDelete(req.params.id);

    res.status(200).json({ success: true, message: 'Expense deleted' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
