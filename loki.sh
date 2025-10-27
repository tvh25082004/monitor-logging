#!/bin/sh

LOKI_URL="http://localhost:3100"

# Hàm query tới Loki API
query_loki() {
  QUERY=$1
  # Lấy thời gian hiện tại và 1 giờ trước (nanoseconds)
  NOW=$(date +%s)000000000
  HOUR_AGO=$((NOW - 3600000000000))
  
  echo "Query: $QUERY"
  echo "----------------------------------------"
  curl -s -G "${LOKI_URL}/loki/api/v1/query_range" \
    --data-urlencode "query=${QUERY}" \
    --data-urlencode "start=${HOUR_AGO}" \
    --data-urlencode "end=${NOW}" \
    --data-urlencode "limit=100" \
  | jq -r '.data.result[]?.values[]?.[1]' 2>/dev/null | grep -v "^$" || echo "Không có logs"
  echo ""
}

case "$1" in
  app|application)
    query_loki '{job="application"}'
    ;;
  nginx)
    query_loki '{job="nginx", log_type="access"}'
    ;;
  mongo|mongodb)
    query_loki '{job="mongodb", log_type="audit"}'
    ;;
  error)
    query_loki '{job="application"} |= "error"'
    ;;
  slow|slowquery)
    query_loki '{job="mongodb", log_type="slowquery"}'
    ;;
  *)
    echo "Usage:"
    echo "  ./loki.sh app           # Application logs"
    echo "  ./loki.sh nginx         # Nginx access logs"
    echo "  ./loki.sh mongo         # MongoDB audit logs"
    echo "  ./loki.sh error         # Application errors"
    echo "  ./loki.sh slow          # MongoDB slow queries"
    echo ""
    echo "Bạn có thể sửa biến LOKI_URL trong script nếu Loki không chạy ở localhost:3100"
    ;;
esac

