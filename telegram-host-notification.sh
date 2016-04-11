#!/bin/bash

TELEGRAM_API_KEY=

if [ -z ${TELEGRAM_API_KEY} ]
then
  echo "kein API KEY vorhanden"
  exit 2
fi

ARCHIV_DIR="/var/log/icinga2/notifications"

[ -d ${ARCHIV_DIR} ] || mkdir -p ${ARCHIV_DIR}

# -----------------------------------------------------------------------------

template=$(cat <<TEMPLATE
> $NOTIFICATIONTYPE <

Host   : $HOSTALIAS
Address: $HOSTADDRESS
State  : $HOSTSTATE

Date/Time: $LONGDATETIME

Additional Info: $HOSTOUTPUT

Comment: [$NOTIFICATIONAUTHORNAME] $NOTIFICATIONCOMMENT
TEMPLATE
)

# -----------------------------------------------------------------------------

echo "${template}" > /var/tmp/notification.body

/usr/bin/curl -X  POST --data chat_id=${USERTELEGRAM} --data text="$(cat /var/tmp/notification.body)" https://api.telegram.org/bot${TELEGRAM_API_KEY}/sendMessage

mv /var/tmp/notification.body ${ARCHIV_DIR}/$(date +"%Y%m%d_%H%M%S").body

exit $?

