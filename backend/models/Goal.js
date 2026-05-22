const mongoose = require('mongoose');

const goalSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  name: {
    type: String,
    required: [true, 'Please provide a goal name'],
    trim: true
  },
  targetAmount: {
    type: Number,
    required: [true, 'Please provide a target amount']
  },
  savedAmount: {
    type: Number,
    default: 0
  },
  deadline: {
    type: Date
  },
  category: {
    type: String,
    default: 'Savings',
    trim: true
  },
  icon: {
    type: String,
    default: 'flag'
  },
  color: {
    type: Number,
    default: 0xFF6366F1
  },
  milestones: [{
    label: String,
    amount: Number,
    completed: {
      type: Boolean,
      default: false
    }
  }],
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

goalSchema.index({ userId: 1, createdAt: -1 });

module.exports = mongoose.model('Goal', goalSchema);
