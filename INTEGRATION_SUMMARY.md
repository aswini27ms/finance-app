# Smart Savings - Backend & Frontend Integration Complete

## Summary of Changes

This document outlines all the updates made to integrate a Node.js/MongoDB backend with your Flutter Smart Savings application.

### Backend Setup (NEW)

A complete Node.js backend with Express and MongoDB has been created with the following structure:

**Directory Structure:**
```
backend/
├── server.js                 # Main server file
├── package.json              # Dependencies
├── .env                       # Environment variables
├── .gitignore                # Git ignore rules
├── models/                   # MongoDB schemas
│   ├── User.js              # User model with authentication
│   ├── Folder.js            # Savings folders model
│   ├── Expense.js           # Expense tracking model
│   └── WishlistItem.js      # Wishlist items model
├── routes/                   # API endpoints
│   ├── auth.js              # Authentication endpoints
│   ├── users.js             # User management
│   ├── folders.js           # Folder CRUD operations
│   ├── expenses.js          # Expense CRUD operations
│   └── wishlist.js          # Wishlist CRUD operations
└── middleware/
    └── auth.js              # JWT authentication middleware
```

**Features:**
- ✅ User registration and login with JWT authentication
- ✅ Password hashing with bcryptjs
- ✅ MongoDB with Mongoose for data persistence
- ✅ RESTful API endpoints for all CRUD operations
- ✅ JWT token-based authorization
- ✅ Error handling and validation
- ✅ CORS enabled for Flutter app connectivity

### Flutter App Updates

#### New Files Created:

1. **API Service** (`lib/services/api_service.dart`)
   - Centralized HTTP client for backend communication
   - JWT token management
   - Generic GET, POST, PUT, DELETE methods
   - Automatic error handling

2. **Auth Service** (`lib/services/auth_service.dart`)
   - User registration
   - User login
   - Get current user
   - Logout functionality

3. **User Service** (`lib/services/user_service.dart`)
   - Get user profile
   - Update user details
   - Update balance

4. **Folder Service** (`lib/services/folder_service.dart`)
   - CRUD operations for folders
   - Add expenses to folders
   - Set folder budgets

5. **Expense Service** (`lib/services/expense_service.dart`)
   - CRUD operations for expenses
   - Get expenses by folder
   - Track spending history

6. **Wishlist Service** (`lib/services/wishlist_service.dart`)
   - CRUD operations for wishlist items
   - Track savings progress
   - Add savings to items

7. **Auth Provider** (`lib/services/auth_provider.dart`)
   - Riverpod state management for authentication
   - Login/register/logout state
   - User information management
   - Error handling

#### Updated Files:

1. **pubspec.yaml**
   - Added `http: ^1.1.0` for HTTP requests
   - Added `shared_preferences: ^2.2.2` for local storage

2. **main.dart**
   - Initialize API service on app startup
   - Set up JWT token persistence

3. **login_screen.dart** - Updated with:
   - Email/password login form
   - Backend API integration
   - Error handling and user feedback
   - Loading states

4. **signup_screen.dart** - Updated with:
   - Name, email, password fields
   - Password confirmation validation
   - Backend registration API call
   - Error handling

5. **savings_service.dart** - Completely refactored:
   - Changed from mock data to backend API calls
   - Implemented AsyncValue for loading states
   - Riverpod providers for data fetching
   - Real-time data synchronization

## How to Set Up and Run

### Prerequisites
- Node.js (v16 or higher) - [Download](https://nodejs.org/)
- MongoDB (v4.4 or higher) - [Download](https://www.mongodb.com/try/download/community)
- Flutter SDK - [Download](https://flutter.dev/docs/get-started/install)
- Git - [Download](https://git-scm.com/)

### Step 1: Start MongoDB

**Windows:**
```bash
# If installed via MSI installer, MongoDB should auto-start
# Or manually start it:
"C:\Program Files\MongoDB\Server\<version>\bin\mongod.exe"
```

**macOS:**
```bash
brew services start mongodb-community
```

**Linux:**
```bash
sudo systemctl start mongod
```

### Step 2: Set Up Backend

```bash
# Navigate to backend folder
cd backend

# Install dependencies
npm install

# Start the server
npm run dev
```

Expected output:
```
Server running on http://localhost:5000
MongoDB connected successfully
```

### Step 3: Update Flutter App Configuration

The Flutter app is already configured to connect to `http://localhost:5000`. 

**For Android Emulator:**
If using Android emulator, change the base URL in `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://10.0.2.2:5000/api';
```

### Step 4: Run Flutter App

```bash
cd smart_savings

# Get dependencies
flutter pub get

# Run the app
flutter run
```

### Step 5: Test the Application

1. **Sign Up:**
   - Open the app
   - Go to "Sign up" screen
   - Enter name, email, password
   - Create account
   
2. **Log In:**
   - After signup, you'll be automatically logged in
   - Or navigate to login and enter credentials

3. **Create Folders:**
   - Go to Dashboard
   - Create new savings folders
   - Set budgets for each folder

4. **Add Expenses:**
   - Add expenses to folders
   - Track spending in real-time
   - View expense history

5. **Manage Wishlist:**
   - Add wishlist items
   - Track savings progress
   - View completion status

## API Endpoints Reference

### Authentication
```
POST   /api/auth/register      - Register new user
POST   /api/auth/login         - Login user
GET    /api/auth/me            - Get current user
```

### Folders
```
GET    /api/folders            - Get all folders
POST   /api/folders            - Create folder
GET    /api/folders/:id        - Get single folder
PUT    /api/folders/:id        - Update folder
DELETE /api/folders/:id        - Delete folder
PUT    /api/folders/:id/add-expense      - Add expense
PUT    /api/folders/:id/set-budget       - Set budget
```

### Expenses
```
GET    /api/expenses           - Get all expenses
POST   /api/expenses           - Create expense
GET    /api/expenses/:id       - Get single expense
GET    /api/expenses/folder/:folderId - Get by folder
PUT    /api/expenses/:id       - Update expense
DELETE /api/expenses/:id       - Delete expense
```

### Wishlist
```
GET    /api/wishlist           - Get all items
POST   /api/wishlist           - Create item
GET    /api/wishlist/:id       - Get single item
PUT    /api/wishlist/:id       - Update item
DELETE /api/wishlist/:id       - Delete item
PUT    /api/wishlist/:id/add-savings    - Add savings
```

### Users
```
GET    /api/users/:id          - Get user details
PUT    /api/users/:id          - Update user
PUT    /api/users/:id/balance  - Update balance
```

## Data Flow

### Authentication Flow
```
User Input → Auth Screen → AuthService → ApiService → Backend → JWT Token → SharedPreferences
```

### Data Fetching Flow
```
Riverpod Provider → Service → ApiService → Backend → Response → State Update → UI
```

## Database Schema

### Users Collection
```javascript
{
  name: String,
  email: String (unique),
  password: String (hashed),
  balance: Number,
  createdAt: Date,
  updatedAt: Date
}
```

### Folders Collection
```javascript
{
  userId: ObjectId,
  name: String,
  icon: String,
  budget: Number,
  spent: Number,
  color: Number,
  createdAt: Date,
  updatedAt: Date
}
```

### Expenses Collection
```javascript
{
  userId: ObjectId,
  folderId: ObjectId,
  amount: Number,
  label: String,
  description: String,
  category: String,
  date: Date,
  createdAt: Date
}
```

### WishlistItems Collection
```javascript
{
  userId: ObjectId,
  name: String,
  price: Number,
  saved: Number,
  dailySaving: Number,
  imageEmoji: String,
  imageUrl: String,
  description: String,
  completed: Boolean,
  createdAt: Date,
  updatedAt: Date
}
```

## Troubleshooting

### Backend Issues

**MongoDB Connection Error**
- Ensure MongoDB is running
- Check MONGODB_URI in `.env`
- Try: `mongosh` to test MongoDB connection

**Port Already in Use**
- Change PORT in `.env` to another number
- Or kill the process: `lsof -ti :5000 | xargs kill -9` (Mac/Linux)

**Dependencies Installation Failed**
- Delete `node_modules` and `package-lock.json`
- Run `npm install` again
- Check Node.js version: `node --version`

### Flutter App Issues

**Connection Refused**
- Backend server not running
- Check backend URL in `api_service.dart`
- For Android emulator, use `10.0.2.2` instead of `localhost`

**Blank Screen After Login**
- Check browser/emulator logs
- Verify backend is responding: `curl http://localhost:5000/health`
- Clear app cache: `flutter clean`

**State Not Updating**
- Ensure API calls return correct response format
- Check Riverpod provider setup
- Debug with print statements in services

## Performance Optimization Tips

1. **Caching:** Implement local caching for frequently accessed data
2. **Pagination:** Add pagination for large expense lists
3. **Batch Operations:** Group related updates together
4. **Indexing:** Database indices are already created on `userId` and `date`

## Security Considerations

### Development Environment
- ✅ CORS enabled for localhost
- ✅ JWT token stored in shared_preferences
- ✅ Passwords hashed with bcryptjs

### Production Changes Needed
1. Change JWT_SECRET in `.env`
2. Enable HTTPS only
3. Update CORS origins
4. Add rate limiting
5. Implement refresh token rotation
6. Add request validation
7. Use environment-specific configs

## Project Structure Summary

### Backend
- **Express Server** with middleware
- **MongoDB** for persistence
- **JWT** for authentication
- **Bcryptjs** for password hashing
- **Error handling** and validation

### Flutter Frontend
- **Riverpod** for state management
- **Shared Preferences** for token storage
- **Http** package for API calls
- **GoRouter** for navigation
- **Material Design** UI

## Next Steps

1. Test the application thoroughly
2. Add input validation and sanitization
3. Implement refresh token logic
4. Add offline support with local database
5. Implement push notifications
6. Add analytics and crash reporting
7. Set up CI/CD pipeline
8. Deploy backend to cloud (Heroku, AWS, etc.)
9. Build and release Flutter app to stores

## Additional Resources

- [MongoDB Documentation](https://docs.mongodb.com/)
- [Express.js Documentation](https://expressjs.com/)
- [Flutter Documentation](https://flutter.dev/docs)
- [Riverpod Documentation](https://riverpod.dev/)
- [JWT Introduction](https://jwt.io/introduction)

## Support

For issues or questions:
1. Check the troubleshooting section
2. Review the logs (check browser console and terminal)
3. Verify environment configuration
4. Test API endpoints with Postman
5. Enable debug logging in services

---

**Integration Status:** ✅ Complete
**Backend:** ✅ Ready
**Frontend:** ✅ Updated  
**Authentication:** ✅ Implemented
**Data Persistence:** ✅ Configured
