const express = require('express');
const router = express.Router();
const Goal = require('../models/Goal');
const protect = require('../middleware/auth');

const buildMilestones = (target, saved) => [0.25, 0.5, 0.75, 1].map((pct) => ({
  label: `${Math.round(pct * 100)}%`,
  amount: Math.round(target * pct),
  completed: saved >= target * pct
}));

router.get('/', protect, async (req, res) => {
  try {
    const goals = await Goal.find({ userId: req.userId }).sort({ createdAt: -1 });
    res.status(200).json({ success: true, goals });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.get('/:id', protect, async (req, res) => {
  try {
    const goal = await Goal.findById(req.params.id);
    if (!goal) return res.status(404).json({ message: 'Goal not found' });
    if (goal.userId.toString() !== req.userId) {
      return res.status(403).json({ message: 'Not authorized' });
    }
    res.status(200).json({ success: true, goal });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.post('/', protect, async (req, res) => {
  try {
    const { name, targetAmount, savedAmount, deadline, category, icon, color } = req.body;
    if (!name || !targetAmount) {
      return res.status(400).json({ message: 'Please provide name and target amount' });
    }

    const target = Number(targetAmount);
    const saved = Number(savedAmount || 0);
    const goal = new Goal({
      userId: req.userId,
      name,
      targetAmount: target,
      savedAmount: saved,
      deadline,
      category: category || 'Savings',
      icon: icon || 'flag',
      color: color || 0xFF6366F1,
      milestones: buildMilestones(target, saved),
      completed: saved >= target
    });

    await goal.save();
    res.status(201).json({ success: true, goal });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.put('/:id', protect, async (req, res) => {
  try {
    let goal = await Goal.findById(req.params.id);
    if (!goal) return res.status(404).json({ message: 'Goal not found' });
    if (goal.userId.toString() !== req.userId) {
      return res.status(403).json({ message: 'Not authorized' });
    }

    const updates = { ...req.body, updatedAt: Date.now() };
    const target = Number(updates.targetAmount || goal.targetAmount);
    const saved = Number(updates.savedAmount ?? goal.savedAmount);
    updates.completed = saved >= target;
    updates.milestones = buildMilestones(target, saved);

    goal = await Goal.findByIdAndUpdate(req.params.id, updates, {
      new: true,
      runValidators: true
    });
    res.status(200).json({ success: true, goal });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.put('/:id/add-savings', protect, async (req, res) => {
  try {
    const { amount, note } = req.body;
    const goal = await Goal.findById(req.params.id);
    if (!goal) return res.status(404).json({ message: 'Goal not found' });
    if (goal.userId.toString() !== req.userId) {
      return res.status(403).json({ message: 'Not authorized' });
    }

    goal.savedAmount = Math.max(0, goal.savedAmount + Number(amount));
    goal.completed = goal.savedAmount >= goal.targetAmount;
    goal.milestones = buildMilestones(goal.targetAmount, goal.savedAmount);
    goal.savingsHistory.push({ amount: Number(amount), note });
    goal.updatedAt = Date.now();
    await goal.save();
    res.status(200).json({ success: true, goal });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.delete('/:id', protect, async (req, res) => {
  try {
    const goal = await Goal.findById(req.params.id);
    if (!goal) return res.status(404).json({ message: 'Goal not found' });
    if (goal.userId.toString() !== req.userId) {
      return res.status(403).json({ message: 'Not authorized' });
    }
    await Goal.findByIdAndDelete(req.params.id);
    res.status(200).json({ success: true, message: 'Goal deleted' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
