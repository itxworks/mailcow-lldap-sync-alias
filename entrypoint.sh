#!/bin/sh

echo "Setting cron schedule: $CRON_SCHEDULE"

echo "$CRON_SCHEDULE /app/email-check >> /var/log/cron.log 2>&1" > /etc/crontabs/root

exec crond -f -L /var/log/cron.log
