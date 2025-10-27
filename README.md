# Hệ Thống Giám Sát Logs với Loki + Promtail + Grafana

Hệ thống tích hợp để thu thập, lưu trữ và hiển thị các loại log từ toàn bộ ứng dụng.

## Cấu Trúc Hệ Thống

```
PLG Stack:
├── Promtail: Thu thập logs từ các nguồn
├── Loki: Lưu trữ và indexing logs
└── Grafana: Visualize logs và tạo dashboards
```

## 4 Loại Log Được Thu Thập

### 1. Application Logs
- **Nguồn**: NestJS backend với Morgan
- **Vị trí**: `/app-logs/*.log`
- **Nội dung**: HTTP requests, API calls, errors

### 2. Audit Logs
- **Application Audit**: User actions, security events
- **MongoDB Audit**: Database operations, authentication
- **Postgres Audit**: Database queries, modifications
- **Vị trí**: `/audit-logs/*/`

### 3. Access Logs
- **Nguồn**: Nginx access & error logs
- **Vị trí**: `/var/log/nginx/*.log`
- **Nội dung**: HTTP requests, errors, response times

### 4. System Logs
- **Nguồn**: OS syslog, auth.log, kernel logs
- **Vị trí**: `/var/log/*`
- **Nội dung**: System events, authentication, kernel logs

## Cài Đặt

### 1. Khởi động hệ thống

```bash
docker compose up -d
```

### 2. Truy cập Grafana

- URL: http://localhost:3000
- Username: `admin`
- Password: `admin`

### 3. Tạo Data Source

Vào **Configuration > Data Sources > Loki**:
- URL: `http://loki:3100`
- Đăng nhập và kiểm tra connection

### 4. Truy vấn Logs

Trong Grafana Explore:

```logql
# Application logs
{job="application"}

# Nginx access logs
{job="nginx", log_type="access"}

# MongoDB audit
{job="mongodb", log_type="audit"}

# Error logs
{job="application"} |= "error"

# Slow queries
{job="mongodb", log_type="slowquery"}
```

## Cấu Hình Các Thành Phần

### NestJS Logger
Sử dụng `config/logger.config.ts` để cấu hình Winston logger.

### MongoDB Audit
Sử dụng `config/mongodb-audit.conf` và mount vào MongoDB container.

### Postgres Audit
Chạy SQL trong `config/postgres-audit.sql` để enable audit logging.

### Nginx Logging
Tham khảo `config/nginx.conf.example` để cấu hình Nginx.

## Kiểm Tra Hệ Thống

```bash
# Xem logs
docker logs loki
docker logs promtail
docker logs grafana

# Kiểm tra Promtail positions
docker exec promtail cat /tmp/positions.yaml

# Test log streaming
echo "test log" >> app-logs/test.log
```

## Cấu Trúc File

```
Monitoring/
├── docker-compose.yml          # Docker setup
├── loki-config.yml            # Loki config
├── promtail-config.yml        # Promtail config
├── grafana-datasources.yml    # Grafana datasources
├── config/                    # Cấu hình mẫu
│   ├── logger.config.ts
│   ├── mongodb-audit.conf
│   ├── postgres-audit.sql
│   └── nginx.conf.example
├── logs/                      # Thư mục log tổng hợp
├── app-logs/                  # Application logs
├── nginx-logs/                # Nginx logs
└── audit-logs/               # Audit logs
    ├── mongodb/
    ├── postgres/
    └── application/
```

## Tối Ưu Hóa

- Giữ logs trong 7 ngày (configured trong loki-config.yml)
- Rotate logs hàng ngày
- Limit log file size (20MB)
- Monitor disk usage

## Troubleshooting

1. **Không có logs trong Grafana**
   - Kiểm tra Promtail: `docker logs promtail`
   - Verify file paths trong `promtail-config.yml`

2. **Container không start**
   - Check ports: `netstat -tuln | grep -E '3000|3100'`
   - Check Docker: `docker ps -a`

3. **Logs không update**
   - Restart Promtail: `docker restart promtail`
   - Check permissions trên log files

## Tài Liệu Tham Khảo

- [Loki Documentation](https://grafana.com/docs/loki/latest/)
- [Promtail Documentation](https://grafana.com/docs/loki/latest/clients/promtail/)
- [Grafana Documentation](https://grafana.com/docs/grafana/latest/)

# monitor-logging
