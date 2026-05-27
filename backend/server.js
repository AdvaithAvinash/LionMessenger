require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');

const authRoutes = require('./src/routes/auth');
const userRoutes = require('./src/routes/users');
const friendRoutes = require('./src/routes/friends');
const streamRoutes = require('./src/routes/stream');
const conversationRoutes = require('./src/routes/conversations');

const app = express();
const PORT = process.env.PORT || 3000;

// Security middleware
app.use(helmet());
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 200,
  message: { error: 'Too many requests, please try again later' },
});

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 20,
  message: { error: 'Too many auth attempts, please try again later' },
});

app.use(limiter);
app.use(morgan('dev'));

// Body parsers — webhook route needs raw body
app.use('/api/auth/webhook', express.raw({ type: 'application/json' }));
app.use(express.json({ limit: '10mb' }));

// Routes
app.use('/api/auth', authLimiter, authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/friends', friendRoutes);
app.use('/api/stream', streamRoutes);
app.use('/api/conversations', conversationRoutes);

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

// Error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Internal server error' });
});

// Only bind a port when running locally — Vercel handles this in production
if (process.env.NODE_ENV !== 'production') {
  app.listen(PORT, () => {
    console.log(`LionMessenger API running on port ${PORT}`);
  });
}

module.exports = app;
