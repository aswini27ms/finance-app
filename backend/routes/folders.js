const express = require('express');
const router = express.Router();
const Folder = require('../models/Folder');
const Expense = require('../models/Expense');
const protect = require('../middleware/auth');

// @route   GET /api/folders
// @desc    Get all folders for a user
// @access  Private
router.get('/', protect, async (req, res) => {
  try {
    const folders = await Folder.find({ userId: req.userId }).sort({ createdAt: -1 });
    res.status(200).json({ success: true, folders });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   GET /api/folders/:id
// @desc    Get single folder
// @access  Private
router.get('/:id', protect, async (req, res) => {
  try {
    const folder = await Folder.findById(req.params.id);
    if (!folder) {
      return res.status(404).json({ message: 'Folder not found' });
    }
    if (folder.userId.toString() !== req.userId) {
      return res.status(403).json({ message: 'Not authorized' });
    }
    res.status(200).json({ success: true, folder });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   POST /api/folders
// @desc    Create a new folder
// @access  Private
router.post('/', protect, async (req, res) => {
  try {
    const { name, icon, budget, color } = req.body;

    if (!name) {
      return res.status(400).json({ message: 'Please provide a folder name' });
    }

    const folder = new Folder({
      userId: req.userId,
      name,
      icon,
      budget: budget || 0,
      color: color || 0xFF6366F1
    });

    await folder.save();
    res.status(201).json({ success: true, folder });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   PUT /api/folders/:id
// @desc    Update a folder
// @access  Private
router.put('/:id', protect, async (req, res) => {
  try {
    let folder = await Folder.findById(req.params.id);
    if (!folder) {
      return res.status(404).json({ message: 'Folder not found' });
    }
    if (folder.userId.toString() !== req.userId) {
      return res.status(403).json({ message: 'Not authorized' });
    }

    const { name, icon, budget, spent, color } = req.body;
    folder = await Folder.findByIdAndUpdate(
      req.params.id,
      { name, icon, budget, spent, color, updatedAt: Date.now() },
      { new: true, runValidators: true }
    );

    res.status(200).json({ success: true, folder });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   DELETE /api/folders/:id
// @desc    Delete a folder
// @access  Private
router.delete('/:id', protect, async (req, res) => {
  try {
    const folder = await Folder.findById(req.params.id);
    if (!folder) {
      return res.status(404).json({ message: 'Folder not found' });
    }
    if (folder.userId.toString() !== req.userId) {
      return res.status(403).json({ message: 'Not authorized' });
    }

    await Expense.deleteMany({ folderId: req.params.id });
    await Folder.findByIdAndDelete(req.params.id);

    res.status(200).json({ success: true, message: 'Folder deleted' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   PUT /api/folders/:id/add-expense
// @desc    Add expense to folder
// @access  Private
router.put('/:id/add-expense', protect, async (req, res) => {
  try {
    const { amount } = req.body;
    let folder = await Folder.findById(req.params.id);
    
    if (!folder) {
      return res.status(404).json({ message: 'Folder not found' });
    }
    if (folder.userId.toString() !== req.userId) {
      return res.status(403).json({ message: 'Not authorized' });
    }

    folder.spent += amount;
    await folder.save();
    res.status(200).json({ success: true, folder });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   PUT /api/folders/:id/set-budget
// @desc    Set budget for a folder
// @access  Private
router.put('/:id/set-budget', protect, async (req, res) => {
  try {
    const { budget } = req.body;
    let folder = await Folder.findById(req.params.id);
    
    if (!folder) {
      return res.status(404).json({ message: 'Folder not found' });
    }
    if (folder.userId.toString() !== req.userId) {
      return res.status(403).json({ message: 'Not authorized' });
    }

    folder.budget = budget;
    await folder.save();
    res.status(200).json({ success: true, folder });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
