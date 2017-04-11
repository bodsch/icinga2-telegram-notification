#!/bin/bash

TELEGRAM_API_KEY=

if [ -f /etc/icinga2/scripts/telegram.rc ]
then
  . /etc/icinga2/scripts/telegram.rc
fi

if [ -z "${TELEGRAM_API_KEY}" ]
then
  echo "kein API KEY vorhanden"
  exit 2
fi

if [ -z "${USERTELEGRAM}" ]
then
  echo "kein Telegram User definiert"
  exit 2
fi

ARCHIV_DIR="/var/log/icinga2/notifications"

[ -d ${ARCHIV_DIR} ] || mkdir -p ${ARCHIV_DIR}

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# -----------------------------------------------------------------------------

cat << EOF > /var/tmp/notification_${TIMESTAMP}.body

> $NOTIFICATIONTYPE <

Host   : $HOSTALIAS
Address: $HOSTADDRESS
State  : $HOSTSTATE

Date/Time: $LONGDATETIME

Additional Info: $HOSTOUTPUT

Comment: [$NOTIFICATIONAUTHORNAME] $NOTIFICATIONCOMMENT

EOF

# -----------------------------------------------------------------------------

/usr/bin/curl \
  --request POST \
  --silent \
  --data chat_id="${USERTELEGRAM}" \
  --data text="$(cat /var/tmp/notification_${TIMESTAMP}.body)"
  https://api.telegram.org/bot${TELEGRAM_API_KEY}/sendMessage

mv /var/tmp/notification_${TIMESTAMP}.body ${ARCHIV_DIR}/$(date +"%Y%m%d_%H%M%S").body

exit 0
