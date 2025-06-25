#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "🚀 Starting AswadXenOS PesterOS Auto‑Setup..."

# Dependencies
pkg update -y && pkg install -y nodejs git python unzip curl
npm install -g pm2

# Project dir
BASE="$HOME/aswadxenos-pesteros"
mkdir -p "$BASE"
cd "$BASE"

# Env file
cat > .env <<EOF
TELEGRAM_TOKEN=YOUR_TELEGRAM_BOT_TOKEN
OPENAI_KEY=YOUR_OPENAI_API_KEY
EOF

# Package manifest
cat > package.json <<EOF
{
  "name": "aswadxenos-pesteros",
  "version": "1.0.0",
  "main": "bot/telegram-bot.js",
  "scripts": {
    "start:bot": "node bot/telegram-bot.js",
    "start:ewallet": "node ewallet/server.js",
    "start:watchdog": "bash security/watchdog/service-loop.sh"
  },
  "dependencies": {
    "axios": "^1.6.7",
    "dotenv": "^16.3.1",
    "node-telegram-bot-api": "^0.61.0"
  }
}
EOF

# Core scripts
chmod +x plugin/runtime/*.sh telco-tools/*.sh hacking-tools/*.sh security/watchdog/service-loop.sh

# Install modules & start services
npm install
pm2 start bot/telegram-bot.js --name bot
pm2 start ewallet/server.js --name ewallet
pm2 start security/watchdog/service-loop.sh --name watchdog

echo "✅ Auto‑setup complete. Use 'pm2 logs' or 'npm run start:bot' to view services."```

### 2. `bot/telegram-bot.js`
```js
const TelegramBot = require('node-telegram-bot-api');
require('dotenv').config();
const bot = new TelegramBot(process.env.TELEGRAM_TOKEN, { polling: true });

// /start
bot.onText(/\/start/, msg => bot.sendMessage(msg.chat.id,
  "✅ PesterOS Bot Aktif! Commands: /status, /scan <target>, /inject <tool>, /tools"));

// /status
bot.onText(/\/status/, msg => bot.sendMessage(msg.chat.id,
  "📡 Semua servis berjalan: Bot, eWallet, Watchdog"));

// /scan <target>
bot.onText(/\/scan (.+)/, (msg, match) => {
  const target = match[1];
  bot.sendMessage(msg.chat.id, `🔎 Recon on: ${target}`);
  // exec multi-agent/multi-tool
});

// /inject <tool>
bot.onText(/\/inject (.+)/, (msg, match) => {
  const tool = match[1];
  bot.sendMessage(msg.chat.id, `⚙️ Running: ${tool}`);
  // spawn hacking-tools/${tool}.sh
});

// /tools
bot.onText(/\/tools/, msg => bot.sendMessage(msg.chat.id,
  "🧰 Available tools: sqlmap, hydra, metasploit, frp, imei"));

// /help
bot.onText(/\/help/, msg => bot.sendMessage(msg.chat.id,
  "Commands: /start, /status, /scan <t>, /inject <tool>, /tools"));
