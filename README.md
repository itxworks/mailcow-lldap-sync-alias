# mailcow-lldap-sync-alias
Update MailCow Database because "Allow to send as" is missing by using LLDAP as MailCow Identity Provider in my personal case.

### Docker Compose 
Add this to you mailcows docker-compose.override.yml

```
  lldap-alias-sync-cron:
    container_name: lldap-sync-alias
    image: ghcr.io/itxworks/mailcow-lldap-sync-alias:latest
    restart: unless-stopped
    environment:
      - DB_USER=${DBUSER}
      - DB_PASS=${DBPASS}
      - DB_HOST=mysql-mailcow
      - DB_NAME=${DBNAME}
      - CRON_SCHEDULE=*/10 * * * *
    networks:
      - mailcow-network
```
