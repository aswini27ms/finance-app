# Quick Start Guide - Smart Savings

## 🚀 Get Running in 5 Minutes

### Prerequisites Check
- [ ] Node.js installed: `node --version`
- [ ] MongoDB installed: `mongosh`
- [ ] Flutter installed: `flutter --version`
- [ ] Git installed

### Start MongoDB (Choose One)

**Option 1: Local MongoDB**
```bash
# Windows - Run as Administrator
mongod

# macOS
brew services start mongodb-community

# Linux
sudo systemctl start mongod
```

**Option 2: MongoDB Atlas (Cloud)**
- Go to https://www.mongodb.com/cloud/atlas
- Create account → Create cluster → Copy connection string
- Replace `MONGODB_URI` in `backend/.env`

### Start Backend

```bash
cd backend
npm install
npm run dev
```

✅ Wait for: `"Server running on http://localhost:5000"`

### Start Flutter App

In a new terminal:
```bash
cd smart_savings
flutter pub get
flutter run
```

### Test the App

1. **Sign Up**
   - Name: John Doe
   - Email: john@example.com
   - Password: password123

2. **Create a Folder**
   - Click "+" button
   - Name: "Emergency Fund"
   - Budget: 10000

3. **Add an Expense**
   - Click on folder
   - Add expense: 500 rupees

4. **Check Dashboard**
   - View updated balance
   - See health score

## 📱 For Android Emulator Users

Edit `lib/services/api_service.dart`:
```dart
// Change this:
static const String baseUrl = 'http://localhost:5000/api';

// To this:
static const String baseUrl = 'http://10.0.2.2:5000/api';
```

## 🔧 Common Issues

| Issue | Solution |
|-------|----------|
| "Connection refused" | Backend not running - check port 5000 |
| "MongoDB connection error" | MongoDB not running - start it first |
| "Blank screen after login" | Clear cache: `flutter clean && flutter run` |
| "Port 5000 already in use" | Change PORT in backend/.env |

## 📚 File Structure

```
smart_savings_flutter/
├── backend/              ← Node.js Server
│   ├── models/          ← Database schemas
│   ├── routes/          ← API endpoints
│   └── server.js        ← Start here
│
└── smart_savings/        ← Flutter App
    ├── lib/
    │   ├── services/    ← API & Auth services
    │   ├── features/    ← App screens
    │   └── main.dart    ← App entry point
    └── pubspec.yaml
```

## 🎯 Key Files to Know

- **Backend API**: `backend/server.js`
- **Database Models**: `backend/models/`
- **API Routes**: `backend/routes/`
- **Flutter API Service**: `lib/services/api_service.dart`
- **Authentication**: `lib/services/auth_provider.dart`
- **Main App**: `lib/main.dart`

## 💾 Database

### View Data (MongoDB)
```bash
mongosh

use smart_savings
db.users.find()
db.folders.find()
db.expenses.find()
db.wishlistitems.find()
```

## 🌐 Test API with Postman

### Register User
```
POST http://localhost:5000/api/auth/register
Body: {
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123"
}
```

### Login
```
POST http://localhost:5000/api/auth/login
Body: {
  "email": "john@example.com",
  "password": "password123"
}
```

### Get Folders
```
GET http://localhost:5000/api/folders
Headers: Authorization: Bearer <your_token>
```

## 🛑 Stop Everything

```bash
# Backend (in terminal 1)
Press Ctrl+C

# Flutter (in terminal 2)
Press Q

# MongoDB
Press Ctrl+C
```

## 📖 Next Steps

1. ✅ Get app running
2. ⬜ Create test account
3. ⬜ Add folders and expenses
4. ⬜ Check MongoDB data
5. ⬜ Test API endpoints
6. ⬜ Read INTEGRATION_SUMMARY.md for detailed info
7. ⬜ Read SETUP_GUIDE.md for deployment

## 🎉 You're All Set!

Your Smart Savings app is now connected to a real backend with MongoDB!

### What Works Now:
- ✅ User registration & login
- ✅ Persistent data storage
- ✅ Real-time updates
- ✅ Multi-user support
- ✅ Full CRUD operations

### Questions?
Check the detailed guides:
- `SETUP_GUIDE.md` - Complete setup instructions
- `INTEGRATION_SUMMARY.md` - Technical details
- `backend/README.md` - Backend documentation

---

**Happy Saving! 💰**
