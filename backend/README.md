# Smart Savings Backend

Backend API for the Smart Savings Flutter Application built with Node.js, Express, and MongoDB.

## Installation

1. Install dependencies:
```bash
npm install
```

2. Create a `.env` file with the following variables:
```
PORT=5000
MONGODB_URI=mongodb://localhost:27017/smart_savings
JWT_SECRET=your_jwt_secret_key_change_this_in_production
JWT_EXPIRE=7d
NODE_ENV=development
```

3. Make sure MongoDB is running on your system

## Running the Server

### Development mode (with auto-reload):
```bash
npm run dev
```

### Production mode:
```bash
npm start
```

The server will start on `http://localhost:5000`

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register a new user
- `POST /api/auth/login` - Login user
- `GET /api/auth/me` - Get current user (requires token)

### Users
- `GET /api/users/:id` - Get user details
- `PUT /api/users/:id` - Update user details
- `PUT /api/users/:id/balance` - Update user balance

### Folders
- `GET /api/folders` - Get all folders
- `GET /api/folders/:id` - Get single folder
- `POST /api/folders` - Create new folder
- `PUT /api/folders/:id` - Update folder
- `DELETE /api/folders/:id` - Delete folder
- `PUT /api/folders/:id/add-expense` - Add expense amount to folder
- `PUT /api/folders/:id/set-budget` - Set folder budget

### Expenses
- `GET /api/expenses` - Get all expenses
- `GET /api/expenses/:id` - Get single expense
- `GET /api/expenses/folder/:folderId` - Get expenses by folder
- `POST /api/expenses` - Create new expense
- `PUT /api/expenses/:id` - Update expense
- `DELETE /api/expenses/:id` - Delete expense

### Wishlist
- `GET /api/wishlist` - Get all wishlist items
- `GET /api/wishlist/:id` - Get single wishlist item
- `POST /api/wishlist` - Create new wishlist item
- `PUT /api/wishlist/:id` - Update wishlist item
- `DELETE /api/wishlist/:id` - Delete wishlist item
- `PUT /api/wishlist/:id/add-savings` - Add savings to wishlist item

## Authentication

Most endpoints require a JWT token. Include it in the request header:
```
Authorization: Bearer <your_jwt_token>
```

## Database

The application uses MongoDB. Update the `MONGODB_URI` in `.env` to point to your MongoDB instance.

### Collections
- `users` - User accounts
- `folders` - Savings folders
- `expenses` - Expense records
- `wishlistitems` - Wishlist items
