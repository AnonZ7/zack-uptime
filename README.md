# zack-uptime

Outside-in check of the sites on the Zack VPS, every 10 minutes from GitHub Actions. It sends a Telegram
message when sites stay down for 2 runs in a row (about 20 minutes), and another when they recover.
It complements `~/zack-watch.sh` on the VPS, which cannot send anything when the VPS itself is dead.

- Secrets: `TELEGRAM_BOT_TOKEN`, `TELEGRAM_CHAT_ID`.
- Run by hand: `gh workflow run uptime -R AnonZ7/zack-uptime`.
- Edit the site list in `check.sh` (`URLS`). Codes 2xx, 3xx and 401 count as up.
- The repo must be public: Actions minutes are free there, while a private repo would use about 4,300 of the
  2,000 free minutes each month.
