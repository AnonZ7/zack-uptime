#!/bin/bash
# Outside-in uptime check for the Zack VPS (runs on GitHub Actions, so it still alerts when the box is dead).
# DOWN after 2 failing runs in a row, RECOVERED after 1 good run. State lives in ./state (actions/cache).
set -u
HOST_IP=155.133.22.236
URLS="https://ains-agency.com https://www.ains-agency.com https://shop.ains-agency.com https://seo.ains-agency.com
https://crm.ains-agency.com https://stage.tahya-cinema.com https://atharli.com https://stage.atharli.com
https://qa.zack-dev.com https://bezness.zack-dev.com https://ains.zack-dev.com https://afe.zack-dev.com/healthz
https://perimlegends.com https://privya-dz.com https://bayya-digital.com https://equiphotel.bayya-digital.com
https://aquagenius.store https://aquagenius.eu https://media.aquagenius.store https://mail.aquagenius.store"

mkdir -p state
code() { curl -s -o /dev/null -m 20 -w '%{http_code}' "$1"; }
ok_code() { case $1 in 2??|3??|401) return 0;; *) return 1;; esac; }

fails=""
for u in $URLS; do
  c=$(code "$u"); ok_code "$c" || { sleep 15; c=$(code "$u"); }
  ok_code "$c" || fails="$fails
$u -> $c"
done
nc -z -w 10 "$HOST_IP" 22 || fails="$fails
ssh port 22 unreachable"

tg() {
  curl -s -m 20 "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
    --data-urlencode "chat_id=${TELEGRAM_CHAT_ID}" --data-urlencode "text=$1" | grep -q '"ok":true'
}

prev=$(cat state/status 2>/dev/null || echo ok)
now=$(date -u '+%F %H:%M UTC')
if [ -z "$fails" ]; then
  [ "$prev" = down ] && tg "Zack RECOVERED (outside check, $now): all sites answer again."
  echo ok > state/status
else
  echo "failing:$fails"
  case $prev in
    ok) echo bad1 > state/status ;;
    bad1) if tg "Zack DOWN (outside check from GitHub, $now):$fails"; then echo down > state/status; fi ;;
    down) : ;;
  esac
fi
echo "status=$(cat state/status)"
