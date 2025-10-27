# Hệ Thống Giám Sát Logs - Tóm Tắt

## ✅ Đã Setup Thành Công

### Cấu Hình Hệ Thống

Hệ thống PLG Stack đã được cài đặt và chạy thành công với các component:

1. **Loki** (Port 3100) - Lưu trữ logs
2. **Promtail** - Thu thập logs từ các nguồn
3. **Grafana** (Port 3000) - Visualize logs

### 4 Loại Log Được Thu Thập

#### 1. Application Logs
- **Vị trí**: `app-logs/*.log`
- **Nguồn**: NestJS backend với Morgan
- **Config**: `config/logger.config.ts`
- **Labels**: `job="application"`

#### 2. Audit Logs
- **Application Audit**: `audit-logs/application/*.log`
- **MongoDB Audit**: `audit-logs/mongodb/*.log`
- **Postgres Audit**: `audit-logs/postgres/*.log`
- **Config**: 
  - MongoDB: `config/mongodb-audit.conf`
  - Postgres: `config/postgres-audit.sql`

#### 3. Access Logs
- **Vị trí**: `nginx-logs/*.log`
- **Nguồn**: Nginx
- **Config**: `config/nginx.conf.example`

#### 4. System Logs (Removed)
- Đã loại bỏ do permission issues với OS logs
- Có thể bật lại sau nếu cần

### Truy Cập

- **Grafana**: http://localhost:3000
  - Username: `admin`
  - Password: `admin`

- **Loki**: http://localhost:3100

### Các File Cấu Hình

```
Monitoring/
├── docker-compose.yml          # Main compose file
├── loki-config.yml             # Loki configuration
├── promtail-config.yml         # Promtail configuration
├── grafana-datasources.yml     # Grafana datasource
├── setup.sh                    # Setup script
├── README.md                   # Tài liệu đầy đủ
├── QUICKSTART.md               # Hướng dẫn nhanh
├── setup-documentation.tex     # LaTeX documentation
├── config/                     # Config files
│   ├── logger.config.ts        # NestJS logger
│   ├── mongodb-audit.conf      # MongoDB audit
│   ├── postgres-audit.sql      # Postgres audit
│   └── nginx.conf.example      # Nginx config
└── [log directories]           # Log directories
```

## 📝 Các Bước Tiếp Theo

### 1. Tích Hợp Với Application Thật

```typescript
// main.ts
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { loggerConfig } from './config/logger.config';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, {
    logger: loggerConfig.logger,
  });
  
  await app.listen(3001);
}
bootstrap();
```

### 2. Setup Nginx (nếu có)

Copy nội dung từ `config/nginx.conf.example` vào Nginx config của bạn.

### 3. Enable MongoDB Audit

```bash
# Mount config vào MongoDB container
docker run -v $(pwd)/config/mongodb-audit.conf:/etc/mongod.conf \
  -v $(pwd)/audit-logs/mongodb:/audit-logs/mongodb \
  mongo --config /etc/mongod.conf
```

### 4. Enable Postgres Audit

Chạy SQL trong `config/postgres-audit.sql` trong Postgres database.

### 5. Tạo Dashboard trong Grafana

1. Vào Grafana > Dashboards > New Dashboard
2. Add Visualization
3. Chọn Data Source: Loki
4. Query: `{job="application"}`
5. Save

## 🔧 Maintenance

### Kiểm Tra Hệ Thống

```bash
# Xem trạng thái
docker compose ps

# Xem logs
docker compose logs -f

# Check Promtail
docker exec promtail cat /tmp/positions.yaml
```

### Backup

```bash
# Backup volumes
docker run --rm -v monitoring_loki-data:/data -v $(pwd):/backup \
  ubuntu tar czf /backup/loki-backup.tar.gz /data
```

### Cleanup

```bash
# Dọn dẹp logs cũ
find app-logs/ -name "*.log" -mtime +7 -delete
find audit-logs/ -name "*.log" -mtime +30 -delete
```

## 📊 Query Examples

### Tìm Errors
```logql
{job="application"} |= "error"
```

### Slow Queries
```logql
{job="mongodb", log_type="slowquery"}
```

### Request Rate
```logql
rate({job="nginx"}[5m])
```

### Filter by Level
```logql
{job="application"} |= "ERROR"
```

## 🎯 Kết Luận

Hệ thống monitoring logs với PLG Stack đã được setup thành công. Tất cả 4 loại log (Application, Audit, Access, System*) đã được cấu hình và sẵn sàng thu thập dữ liệu.

*System logs đã được loại bỏ để tránh permission issues, có thể enable lại nếu cần.

Chạy `docker compose up -d` để khởi động hệ thống và truy cập Grafana tại http://localhost:3000 để bắt đầu xem logs.

