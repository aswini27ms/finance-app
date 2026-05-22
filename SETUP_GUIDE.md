# Smart Savings - Complete Setup Guide

## Backend Setup (Node.js + MongoDB)

### Prerequisites
- Node.js (v16 or higher)
- MongoDB (v4.4 or higher)
- npm or yarn package manager

### Step 1: Install Node.js Dependencies

Navigate to the backend folder:
```bash
cd backend
npm install
```

### Step 2: Install MongoDB

#### Option A: Local MongoDB Installation
- Download from: https://www.mongodb.com/try/download/community
- Install and run MongoDB service

#### Option B: MongoDB Atlas (Cloud)
1. Go to https://www.mongodb.com/cloud/atlas
2. Create a free account
3. Create a cluster
4. Get your connection string
5. Update the `MONGODB_URI` in `.env`

### Step 3: Configure Environment Variables

Edit `backend/.env` file:
```
PORT=5000
MONGODB_URI=mongodb://localhost:27017/smart_savings
JWT_SECRET=your_very_secure_secret_key_change_this
JWT_EXPIRE=7d
NODE_ENV=development
```

### Step 4: Start the Backend Server

```bash
npm run dev
```

The server will run on `http://localhost:5000`

You should see: "Server running on http://localhost:5000" and "MongoDB connected successfully"

## Flutter App Setup

### Step 1: Install Flutter Dependencies

Navigate to the Flutter project folder:
```bash
cd smart_savings
flutter pub get
```

### Step 2: Update API Configuration

If your backend is NOT running on `http://localhost:5000`, update the base URL in:
- `lib/services/api_service.dart` - Change `baseUrl` to your backend URL

### Step 3: Configure for Different Platforms

#### Android
No additional configuration needed. The app connects to `http://localhost:5000` by default.

#### iOS
Update the ATS settings if needed in `ios/Runner/Info.plist`:
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
    <key>NSExceptionDomains</key>
    <dict>
        <key>localhost</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
        </dict>
    </dict>
</dict>
```

### Step 4: Run the Flutter App

```bash
flutter run
```

## Features

### Authentication
- User registration with email and password
- JWT token-based authentication
- Secure token storage in shared preferences
- Auto-logout on token expiration

### Folders & Budgets
- Create custom savings folders
- Set budgets for each folder
- Track spending across folders
- Folder-specific categories

### Expenses
- Add expenses to folders
- View expense history
- Filter expenses by folder
- Edit and delete expenses

### Wishlist
- Create wishlist items
- Track progress towards goals
- Set daily saving targets
- Mark items as completed

### Dashboard
- View total balance
- See spending summary
- Financial health score
- Savings streak tracking

## API Documentation

### Base URL
```
http://localhost:5000/api
```

### Authentication Header
```
Authorization: Bearer <your_jwt_token>
```

### Common Endpoints

#### Auth
- `POST /auth/register` - Register new user
- `POST /auth/login` - Login user
- `GET /auth/me` - Get current user

#### Folders
- `GET /folders` - Get all folders
- `POST /folders` - Create folder
- `PUT /folders/:id` - Update folder
- `DELETE /folders/:id` - Delete folder

#### Expenses
- `GET /expenses` - Get all expenses
- `POST /expenses` - Create expense
- `PUT /expenses/:id` - Update expense
- `DELETE /expenses/:id` - Delete expense

#### Wishlist
- `GET /wishlist` - Get all wishlist items
- `POST /wishlist` - Create wishlist item
- `PUT /wishlist/:id` - Update wishlist item
- `DELETE /wishlist/:id` - Delete wishlist item

## Troubleshooting

### Backend Connection Issues

**Error: "Failed to fetch"**
- Check if backend server is running on port 5000
- Verify MongoDB connection string
- Check firewall settings

**Error: "MongoDB connection error"**
- Ensure MongoDB is running
- Verify MONGODB_URI in `.env`
- Check MongoDB credentials

### Flutter App Issues

**Error: "Connection refused"**
- Backend server is not running
- Check backend URL in `api_service.dart`
- For Android emulator, use `10.0.2.2` instead of `localhost`

**Error: "Unauthorized"**
- Token has expired, need to re-login
- Token is invalid, clear cache and re-login

## Performance Tips

1. **Database Indexing**: Indices are already created on frequently queried fields
2. **Caching**: Implement local caching in Flutter for better UX
3. **Pagination**: Add pagination for large lists of expenses
4. **Rate Limiting**: Consider adding rate limiting to API endpoints

## Security Notes

1. **JWT Secret**: Change the JWT_SECRET in production
2. **HTTPS**: Use HTTPS in production
3. **CORS**: Update CORS origins in production
4. **Password Hashing**: Passwords are hashed using bcryptjs
5. **Environment Variables**: Never commit `.env` file to version control

## Deployment

### Backend Deployment (Heroku)
1. Create Heroku account
2. Install Heroku CLI
3. `heroku create your-app-name`
4. Set environment variables: `heroku config:set MONGODB_URI=your_mongo_uri`
5. `git push heroku main`

### Flutter Deployment
- Android: `flutter build apk` or `flutter build appbundle`
- iOS: `flutter build ipa`
- Update API URLs for production

For more information, refer to the README files in `/backend` and `/smart_savings` directories.
