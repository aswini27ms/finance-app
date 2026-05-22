require("dotenv").config();
const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");

const app = express();

// ── Middleware ────────────────────────────────────────────────────────────────
app.use(express.json());
app.use(cors({ origin: true, credentials: true }));

// ── Root route ────────────────────────────────────────────────────────────────
app.get("/", (_, res) =>
  res.json({
    message: "Smart Savings API",
    version: "1.0.0",
    status: "running",
  }),
);

// ── MongoDB connection ────────────────────────────────────────────────────────
const MONGO_URI = process.env.MONGODB_URI;

if (!MONGO_URI) {
  console.error(
    "❌  MONGODB_URI is not set in .env — server will start but DB calls will fail",
  );
} else {
  console.log("🔗  Connecting to MongoDB Atlas...");
}

mongoose
  .connect(MONGO_URI, {
    serverSelectionTimeoutMS: 15000,
    socketTimeoutMS: 30000,
  })
  .then(() => console.log("✅  MongoDB Atlas connected successfully"))
  .catch((err) => {
    console.error("❌  MongoDB connection error:", err.message);
    console.error("");
    console.error("  Common causes:");
    console.error("  1. Port 27017 blocked by Windows Firewall / router");
    console.error("     Fix: switch to mobile hotspot or run as admin:");
    console.error(
      '     New-NetFirewallRule -DisplayName "MongoDB Atlas" -Direction Outbound -Protocol TCP -RemotePort 27017 -Action Allow',
    );
    console.error("");
    console.error("  2. Wrong password in .env (@ in password must be %40)");
    console.error("     Check: MONGODB_URI in .env has %40 not @");
    console.error("");
    console.error("  3. Atlas cluster is paused");
    console.error("     Fix: go to cloud.mongodb.com → Resume cluster");
  });

// ── Routes ────────────────────────────────────────────────────────────────────
app.use("/api/auth", require("./routes/auth"));
app.use("/api/users", require("./routes/users"));
app.use("/api/folders", require("./routes/folders"));
app.use("/api/expenses", require("./routes/expenses"));
app.use("/api/wishlist", require("./routes/wishlist"));
app.use("/api/transactions", require("./routes/transactions"));
app.use("/api/goals", require("./routes/goals"));

// ── Health check ──────────────────────────────────────────────────────────────
app.get("/health", (_, res) => {
  const dbState = ["disconnected", "connected", "connecting", "disconnecting"];
  res.json({
    status: "Backend is running",
    database: dbState[mongoose.connection.readyState] ?? "unknown",
    timestamp: new Date(),
  });
});

// ── Error handler ─────────────────────────────────────────────────────────────
app.use((err, req, res, next) => {
  console.error(err.stack);
  res
    .status(err.status || 500)
    .json({ message: err.message, status: err.status || 500 });
});

// ── Start ─────────────────────────────────────────────────────────────────────
const PORT = process.env.PORT || 5000;
app.listen(PORT, () =>
  console.log(`🚀  Server running on http://localhost:${PORT}`),
);
