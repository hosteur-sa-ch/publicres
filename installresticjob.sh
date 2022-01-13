#!/bin/bash
cat > /root/hosteurbackup.sh <<-EOM
#!/bin/bash
export AZURE_ACCOUNT_NAME=${AZURE_ACCOUNT_NAME}
export AZURE_ACCOUNT_KEY=${AZURE_ACCOUNT_KEY}
export RESTIC_REPOSITORY=azure:$1:/
export RESTIC_PASSWORD=${RESTIC_PASSWORD}
restic backup -o azure.connections=10 --tag Scheduled $2 >>/var/log/hosteurbackup.log 2>/var/log/hosteurbackup_err.log
restic forget --keep-daily 7 --keep-monthly 1 --keep-yearly 1 --tag Scheduled >>/var/log/hosteurbackup.log 2>>/var/log/hosteurbackup_err.log
restic prune >>/var/log/hosteurbackup.log 2>>/var/log/hosteurbackup_err.log
EOM

echo "0 12 1-31/2 * * /root/hosteurbackup.sh >/dev/null 2>&1" >> /etc/crontab
cat > /etc/logrotate.d/restic <<-EOM
/var/log/hosteurbackup.log {
    missingok
    notifempty
    maxsize 30k
    yearly
    create 0600 root root
}
/var/log/hosteurbackup_err.log {
    missingok
    notifempty
    maxsize 30k
    yearly
    create 0600 root root
}
EOM
