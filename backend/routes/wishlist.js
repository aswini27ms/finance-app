const express = require('express');
const router = express.Router();
const WishlistItem = require('../models/WishlistItem');
const protect = require('../middleware/auth');

// @route   GET /api/wishlist
// @desc    Get all wishlist items for a user
// @access  Private
router.get('/', protect, async (req, res) => {
  try {
    const items = await WishlistItem.find({ userId: req.userId }).sort({ createdAt: -1 });
    res.status(200).json({ success: true, items });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   GET /api/wishlist/:id
// @desc    Get single wishlist item
// @access  Private
router.get('/:id', protect, async (req, res) => {
  try {
    const item = await WishlistItem.findById(req.params.id);
    if (!item) {
      return res.status(404).json({ message: 'Wishlist item not found' });
    }
    if (item.userId.toString() !== req.userId) {
      return res.status(403).json({ message: 'Not authorized' });
    }
    res.status(200).json({ success: true, item });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   POST /api/wishlist
// @desc    Create a new wishlist item
// @access  Private
router.post('/', protect, async (req, res) => {
  try {
    const {
      name,
      price,
      imageEmoji,
      imageUrl,
      merchantUrl,
      merchantName,
      description,
      dailySaving,
      monthlySaving,
      category,
      priority,
      expectedPurchaseDate
    } = req.body;

    if (!name || !price) {
      return res.status(400).json({ message: 'Please provide name and price' });
    }

    const item = new WishlistItem({
      userId: req.userId,
      name,
      price,
      imageEmoji: imageEmoji || '🎁',
      imageUrl,
      merchantUrl: merchantUrl || '',
      merchantName: merchantName || '',
      description,
      dailySaving: dailySaving || 0,
      monthlySaving: monthlySaving || 0,
      category: category || 'General',
      priority: priority || 'Medium',
      expectedPurchaseDate
    });

    await item.save();
    res.status(201).json({ success: true, item });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   PUT /api/wishlist/:id
// @desc    Update a wishlist item
// @access  Private
router.put('/:id', protect, async (req, res) => {
  try {
    let item = await WishlistItem.findById(req.params.id);
    if (!item) {
      return res.status(404).json({ message: 'Wishlist item not found' });
    }
    if (item.userId.toString() !== req.userId) {
      return res.status(403).json({ message: 'Not authorized' });
    }

    const {
      name,
      price,
      saved,
      dailySaving,
      monthlySaving,
      imageEmoji,
      imageUrl,
      merchantUrl,
      merchantName,
      description,
      category,
      priority,
      expectedPurchaseDate,
      completed
    } = req.body;
    item = await WishlistItem.findByIdAndUpdate(
      req.params.id,
      {
        name,
        price,
        saved,
        dailySaving,
        monthlySaving,
        imageEmoji,
        imageUrl,
        merchantUrl,
        merchantName,
        description,
        category,
        priority,
        expectedPurchaseDate,
        completed,
        updatedAt: Date.now()
      },
      { new: true, runValidators: true }
    );

    res.status(200).json({ success: true, item });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   DELETE /api/wishlist/:id
// @desc    Delete a wishlist item
// @access  Private
router.delete('/:id', protect, async (req, res) => {
  try {
    const item = await WishlistItem.findById(req.params.id);
    if (!item) {
      return res.status(404).json({ message: 'Wishlist item not found' });
    }
    if (item.userId.toString() !== req.userId) {
      return res.status(403).json({ message: 'Not authorized' });
    }

    await WishlistItem.findByIdAndDelete(req.params.id);
    res.status(200).json({ success: true, message: 'Wishlist item deleted' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   PUT /api/wishlist/:id/add-savings
// @desc    Add savings to a wishlist item
// @access  Private
router.put('/:id/add-savings', protect, async (req, res) => {
  try {
    const { amount, note } = req.body;
    let item = await WishlistItem.findById(req.params.id);
    
    if (!item) {
      return res.status(404).json({ message: 'Wishlist item not found' });
    }
    if (item.userId.toString() !== req.userId) {
      return res.status(403).json({ message: 'Not authorized' });
    }

    item.saved = Math.max(0, item.saved + Number(amount));
    item.savingsHistory.push({ amount: Number(amount), note });
    if (item.saved >= item.price) {
      item.completed = true;
    }
    item.updatedAt = Date.now();
    await item.save();
    res.status(200).json({ success: true, item });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
