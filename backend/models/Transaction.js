const mongoose = require('mongoose');

const transactionSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  type: { type: String, enum: ['income', 'expense'], required: true },
  amount: { type: Number, required: true },
  label: { type: String, required: true },
  category: { type: String, default: 'general' },
  merchant: { type: String, default: '' },
  folderId: { type: mongoose.Schema.Types.ObjectId, ref: 'Folder' },
  date: { type: Date, default: Date.now },
}, { timestamps: true });

module.exports = mongoose.model('Transaction', transactionSchema);
