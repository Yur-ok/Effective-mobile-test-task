#!/bin/bash

PROCESS_NAME="test"
CHECK_URL="https://test.com/monitoring/test/api"
LOG_FILE="/var/log/monitoring.log"
CURL_TIMEOUT=10
LOCK_FILE="/var/run/monitor-test.lock"


log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $*" >> "$LOG_FILE"
}


if ! mkdir "$LOCK_FILE" 2>/dev/null; then
    log "WARNING: Скрипт уже запущен (lock файл существует). Пропускаем выполнение."
    exit 0
fi
trap 'rm -rf "$LOCK_FILE"' EXIT


if pgrep -x "$PROCESS_NAME" > /dev/null; then
    log "OK: Процесс $PROCESS_NAME найден (PID: $(pgrep -x $PROCESS_NAME | tr '\n' ',' | sed 's/,$//'))."

    # === Делаем запрос на API ===
    if curl -f -s --max-time "$CURL_TIMEOUT" "$CHECK_URL" > /dev/null; then
        log "OK: Успешно стукнулись в $CHECK_URL (HTTP 200)"
    else
        curl_exit_code=$?
        log "ERROR: Не удалось достучаться до $CHECK_URL (curl exit code: $curl_exit_code)"
    fi
else
    log "WARNING: Процесс $PROCESS_NAME НЕ запущен"
fi

exit 0
