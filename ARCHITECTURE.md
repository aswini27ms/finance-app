# Project Architecture & File Structure

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     FLUTTER MOBILE APP                       │
│                     (Smart Savings)                          │
├─────────────────────────────────────────────────────────────┤
│  Screens        │ State Management │ Services               │
│  ─────────────  │ ────────────────  │ ────────────────      │
│  - Dashboard    │ - Riverpod       │ - api_service        │
│  - Login        │ - StateProvider  │ - auth_service       │
│  - Signup       │ - FutureProvider │ - folder_service     │
│  - Folders      │ - AsyncValue     │ - expense_service    │
│  - Wishlist     │                  │ - wishlist_service   │
└────────────┬────────────────────────────────────────────────┘
             │ HTTP/REST
             ↓
┌─────────────────────────────────────────────────────────────┐
│           NODE.JS / EXPRESS BACKEND SERVER                  │
│                  (Smart Savings API)                        │
├─────────────────────────────────────────────────────────────┤
│  Routes              │ Middleware      │ Controllers        │
│  ──────────────────  │ ────────────────  │ ───────────────  │
│  - /auth/register    │ - Authentication │ - validateInput   │
│  - /auth/login       │ - Error Handler  │ - hashPassword    │
│  - /folders          │ - CORS           │ - verifyToken     │
│  - /expenses         │                  │                   │
│  - /wishlist         │                  │                   │
│  - /users            │                  │                   │
└────────────┬────────────────────────────────────────────────┘
             │ Mongoose/Driver
             ↓
┌─────────────────────────────────────────────────────────────┐
│              MONGODB DATABASE                               │
│              (Data Persistence)                             │
├─────────────────────────────────────────────────────────────┤
│  Collections:                                               │
│  - users (Authentication & Profile)                        │
│  - folders (Savings Categories)                            │
│  - expenses (Transaction History)                          │
│  - wishlistitems (Goal Tracking)                           │
└─────────────────────────────────────────────────────────────┘
```

## 📁 Complete File Structure

```
smart_savings_flutter/
│
├── 📄 QUICKSTART.md                    [Quick start guide]
├── 📄 SETUP_GUIDE.md                   [Complete setup instructions]
├── 📄 INTEGRATION_SUMMARY.md           [Integration details]
├── 📄 ARCHITECTURE.md                  [This file]
│
├── backend/                            [NODE.JS BACKEND]
│   ├── server.js                       [Main server file]
│   ├── package.json                    [Dependencies list]
│   ├── .env                            [Environment config]
│   ├── .gitignore                      [Git ignore rules]
│   ├── README.md                       [Backend documentation]
│   │
│   ├── models/                         [MongoDB Schemas]
│   │   ├── User.js                     [User model with auth]
│   │   ├── Folder.js                   [Folder/Category model]
│   │   ├── Expense.js                  [Expense transaction model]
│   │   └── WishlistItem.js             [Wishlist item model]
│   │
│   ├── routes/                         [API Endpoints]
│   │   ├── auth.js                     [Auth endpoints]
│   │   ├── users.js                    [User management]
│   │   ├── folders.js                  [Folder CRUD]
│   │   ├── expenses.js                 [Expense CRUD]
│   │   └── wishlist.js                 [Wishlist CRUD]
│   │
│   └── middleware/
│       └── auth.js                     [JWT middleware]
│
└── smart_savings/                      [FLUTTER APP]
    ├── pubspec.yaml                    [Flutter dependencies + http + shared_preferences]
    ├── lib/
    │   │
    │   ├── main.dart                   [App entry point - UPDATED]
    │   │
    │   ├── services/                   [Business Logic Layer]
    │   │   ├── api_service.dart        [HTTP client NEW]
    │   │   ├── auth_service.dart       [Auth API calls NEW]
    │   │   ├── auth_provider.dart      [Auth state mgmt NEW]
    │   │   ├── user_service.dart       [User API calls NEW]
    │   │   ├── folder_service.dart     [Folder API calls NEW]
    │   │   ├── expense_service.dart    [Expense API calls NEW]
    │   │   ├── wishlist_service.dart   [Wishlist API calls NEW]
    │   │   ├── savings_service.dart    [State providers - REFACTORED]
    │   │   └── ai_coach_service.dart   [AI Coach service]
    │   │
    │   ├── features/                   [Screen Components]
    │   │   ├── auth/
    │   │   │   ├── login_screen.dart   [Login - UPDATED]
    │   │   │   ├── signup_screen.dart  [Signup - UPDATED]
    │   │   │   └── _auth_shell.dart    [Auth layout wrapper]
    │   │   ├── dashboard/              [Dashboard screens]
    │   │   ├── folders/                [Folder management]
    │   │   ├── analytics/              [Analytics screens]
    │   │   ├── wishlist/               [Wishlist screens]
    │   │   ├── settings/               [Settings screens]
    │   │   ├── profile/                [Profile screens]
    │   │   └── onboarding/             [Onboarding screens]
    │   │
    │   ├── routes/
    │   │   └── app_router.dart         [Navigation routing]
    │   │
    │   ├── theme/
    │   │   ├── app_theme.dart          [UI theme]
    │   │   ├── app_colors.dart         [Color palette]
    │   │   ├── app_spacing.dart        [Spacing constants]
    │   │   └── theme_controller.dart   [Theme state]
    │   │
    │   ├── config/
    │   │   ├── app_constants.dart      [App configuration]
    │   │   └── mock_data.dart          [Old mock data - deprecated]
    │   │
    │   ├── utils/
    │   │   ├── formatters.dart         [Formatting utilities]
    │   │   └── icon_resolver.dart      [Icon utilities]
    │   │
    │   └── shared/
    │       ├── components/             [Reusable components]
    │       └── widgets/                [Custom widgets]
    │
    ├── assets/                         [App assets]
    ├── test/                           [Unit tests]
    ├── android/                        [Android config]
    ├── ios/                            [iOS config]
    ├── web/                            [Web config]
    ├── windows/                        [Windows config]
    ├── macos/                          [macOS config]
    └── linux/                          [Linux config]
```

## 🔄 Data Flow Diagram

### User Registration Flow
```
SignupScreen
    ↓
User enters: name, email, password
    ↓
GradientButton clicked
    ↓
auth_provider.register()
    ↓
AuthService.register()
    ↓
ApiService.post('/auth/register')
    ↓
Backend receives: POST /api/auth/register
    ↓
Backend validates input
    ↓
Backend hashes password with bcryptjs
    ↓
Backend creates User in MongoDB
    ↓
Backend generates JWT token
    ↓
Backend returns: { success: true, token, user }
    ↓
ApiService.saveToken(token)
    ↓
SharedPreferences saves token
    ↓
authProvider updates state
    ↓
App navigates to Dashboard
```

### Data Fetching Flow
```
Dashboard opened
    ↓
folderProvider watched by UI
    ↓
FoldersNotifier._fetchFolders()
    ↓
FolderService.getFolders()
    ↓
ApiService.get('/folders')
    ↓
HTTP GET with JWT token
    ↓
Backend receives: GET /api/folders
    ↓
Backend extracts userId from JWT
    ↓
Backend queries MongoDB: Folder.find({ userId })
    ↓
Backend returns: { success: true, folders: [...] }
    ↓
ApiService parses response
    ↓
FoldersNotifier converts to Folder objects
    ↓
State updated: AsyncValue.data(folders)
    ↓
UI rebuilds with new data
    ↓
User sees folders on Dashboard
```

## 🔐 Authentication Flow

```
┌─ Login ──────────────────────────────────────────────┐
│                                                      │
│  1. User enters email & password                    │
│  2. Frontend sends: POST /auth/login                │
│  3. Backend verifies credentials                    │
│  4. Backend creates JWT token                       │
│  5. Frontend stores token in SharedPreferences      │
│  6. Frontend includes token in all requests         │
│  7. Backend validates token on every request        │
│  8. Backend returns user data                       │
│  9. App navigates to Dashboard                      │
│                                                      │
│  Token expires? → Auto-logout → Login again        │
└──────────────────────────────────────────────────────┘
```

## 🗄️ MongoDB Collections Schema

### Users Collection
```javascript
{
  _id: ObjectId,
  name: "John Doe",
  email: "john@example.com",
  password: "$2a$10$...", // hashed
  balance: 50000,
  createdAt: ISODate("2024-01-01"),
  updatedAt: ISODate("2024-01-01")
}
```

### Folders Collection
```javascript
{
  _id: ObjectId,
  userId: ObjectId("user_id"),
  name: "Emergency",
  icon: "shield",
  budget: 10000,
  spent: 2500,
  color: 4287645470, // 0xFF22C55E
  createdAt: ISODate("2024-01-01"),
  updatedAt: ISODate("2024-01-15")
}
```

### Expenses Collection
```javascript
{
  _id: ObjectId,
  userId: ObjectId("user_id"),
  folderId: ObjectId("folder_id"),
  amount: 500,
  label: "Groceries",
  description: "Weekly shopping",
  category: "food",
  date: ISODate("2024-01-15"),
  createdAt: ISODate("2024-01-15")
}
```

### WishlistItems Collection
```javascript
{
  _id: ObjectId,
  userId: ObjectId("user_id"),
  name: "MacBook Pro",
  price: 180000,
  saved: 50000,
  dailySaving: 500,
  imageEmoji: "💻",
  imageUrl: null,
  description: "Work laptop",
  completed: false,
  createdAt: ISODate("2024-01-01"),
  updatedAt: ISODate("2024-01-15")
}
```

## 🔌 API Endpoints Organized by Feature

### Authentication Module
```
POST   /api/auth/register    → Register new user
POST   /api/auth/login       → Login user
GET    /api/auth/me          → Get current user (requires auth)
```

### User Management Module
```
GET    /api/users/:id                → Get user profile
PUT    /api/users/:id                → Update profile
PUT    /api/users/:id/balance        → Update balance
```

### Folder Management Module
```
GET    /api/folders                  → List all folders
POST   /api/folders                  → Create folder
GET    /api/folders/:id              → Get folder details
PUT    /api/folders/:id              → Update folder
DELETE /api/folders/:id              → Delete folder
PUT    /api/folders/:id/add-expense  → Add expense amount
PUT    /api/folders/:id/set-budget   → Update budget
```

### Expense Tracking Module
```
GET    /api/expenses                 → List all expenses
POST   /api/expenses                 → Create expense
GET    /api/expenses/:id             → Get expense details
PUT    /api/expenses/:id             → Update expense
DELETE /api/expenses/:id             → Delete expense
GET    /api/expenses/folder/:folderId → Get folder expenses
```

### Wishlist Management Module
```
GET    /api/wishlist                 → List all items
POST   /api/wishlist                 → Create item
GET    /api/wishlist/:id             → Get item details
PUT    /api/wishlist/:id             → Update item
DELETE /api/wishlist/:id             → Delete item
PUT    /api/wishlist/:id/add-savings → Add savings amount
```

## 📊 State Management Architecture

### Riverpod Providers

#### Simple State Providers
- `userIdProvider` - Current user ID
- `balanceProvider` - User balance (FutureProvider)
- `savingsStreakProvider` - Streak count (StateProvider)

#### State Notifier Providers
- `foldersProvider` - Folder list with CRUD (AsyncValue)
- `expensesProvider` - Expense list with CRUD (AsyncValue)
- `wishlistProvider` - Wishlist items with CRUD (AsyncValue)

#### Auth Provider
- `authProvider` - Authentication state with login/logout
- `isAuthenticatedProvider` - Quick auth check
- `userNameProvider` - User name selector
- `userEmailProvider` - User email selector

## 🚀 Deployment Architecture

### Local Development
```
Frontend: Flutter on emulator/device  →  Backend: Node.js localhost:5000  →  MongoDB: localhost:27017
```

### Production Setup
```
Frontend: Flutter App (App Store/Play Store)  →  Backend: Cloud Server (AWS/Heroku)  →  MongoDB: Atlas (Cloud)
```

## 📱 Platform-Specific Notes

### Android
- Uses `http://10.0.2.2:5000` in emulator (special alias for localhost)
- Uses `http://actual-ip:5000` on physical device

### iOS
- Uses `http://localhost:5000` on simulator
- Requires HTTP exceptions in Info.plist
- Uses `http://actual-ip:5000` on physical device

### Web
- Can use `http://localhost:5000` directly
- Requires CORS headers from backend

## 🔄 Request/Response Cycle

```
1. Frontend Action
   ↓
2. Service Method Called
   ↓
3. ApiService.post/get/put/delete()
   ↓
4. HTTP Request with JWT token
   ↓
5. Backend Middleware - Verify JWT
   ↓
6. Backend Route Handler
   ↓
7. MongoDB Operation
   ↓
8. Response Created
   ↓
9. Frontend receives JSON
   ↓
10. Service parses response
   ↓
11. Riverpod state updated
   ↓
12. UI rebuilds with new data
```

## 🛡️ Error Handling Flow

```
Error Occurs
   ↓
Backend sends error response (4xx or 5xx)
   ↓
ApiService._handleResponse() catches it
   ↓
Throws Exception with message
   ↓
Service catches exception
   ↓
State updated with error
   ↓
UI shows error message/snackbar
   ↓
User can retry or navigate away
```

---

**Architecture Status:** ✅ Complete and Production-Ready
