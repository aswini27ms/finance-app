const mongoose = require('mongoose');

const wishlistItemSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  name: {
    type: String,
    required: [true, 'Please provide a wishlist item name'],
    trim: true
  },
  price: {
    type: Number,
    required: [true, 'Please provide a price']
  },
  saved: {
    type: Number,
    default: 0
  },
  dailySaving: {
    type: Number,
    default: 0
  },
  monthlySaving: {
    type: Number,
    default: 0
  },
  category: {
    type: String,
    default: 'General',
    trim: true
  },
  priority: {
    type: String,
    enum: ['Low', 'Medium', 'High'],
    default: 'Medium'
  },
  imageEmoji: {
    type: String,
    default: '🎁'
  },
  imageUrl: {
    type: String
  },
  merchantUrl: {
    type: String,
    trim: true,
    default: ''
  },
  merchantName: {
    type: String,
    trim: true,
    default: ''
  },
  description: {
    type: String,
    trim: true
  },
  expectedPurchaseDate: {
    type: Date
  },
  savingsHistory: [{
    amount: {
      type: Number,
      required: true
    },
    note: {
      type: String,
      trim: true
    },
    date: {
      type: Date,
      default: Date.now
    }
  }],
  completed: {
    type: Boolean,
    default: false
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('WishlistItem', wishlistItemSchema);
