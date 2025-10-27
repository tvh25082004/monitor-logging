# Quick Start - Hệ Thống Giám Sát Logs PLG Stack

## 🚀 Khởi Động Nhanh

### 1. Chạy Setup Script

```bash
./setup.sh
```

Hoặc chạy thủ công:

```bash
# Khởi động containers
docker compose up -d

# Kiểm tra trạng thái
docker compose ps

# Xem logs
docker compose logs -f promtail
```

### 2. Truy Cập Grafana

- **URL**: http://localhost:3000
- **Username**: admin
- **Password**: admin

### 3. Kiểm Tra Loki

- **URL**: http://localhost:3100/ready

## 📊 Query Logs trong Grafana

Vào **Explore** trong Grafana và thử các query sau:

```logql
# Xem tất cả application logs
{job="application"}

# Tìm errors
{job="application"} |= "error"

# Nginx logs
{job="nginx"}

# MongoDB audit logs
{job="mongodb", log_type="audit"}

# Filter theo level
{job="application"} |= "ERROR"

# Search trong nội dung
{job="nginx"} |~ "POST"
```

## 🔧 Các Lệnh Quản Lý

```bash
# Xem logs của containers
docker logs loki -f
docker logs promtail -f
docker logs grafana -f

# Restart containers
docker compose restart

# Stop hệ thống
docker compose down

# Stop và xóa volumes
docker compose down -v

# Update config
docker compose restart promtail
```

## 📁 Cấu Trúc Thư Mục Logs

```
Monitoring/
├── app-logs/              # Application logs (NestJS)
├── nginx-logs/            # Nginx access/error logs
└── audit-logs/            # Audit logs
    ├── mongodb/           # MongoDB audit
    ├── postgres/          # Postgres audit
    └── application/       # Application audit
```

## 🔍 Troubleshooting

### Promtail không thu thập logs

```bash
# Check Promtail config
docker exec promtail cat /etc/promtail/config.yml

# Check Promtail logs
docker logs promtail

# Check positions
docker exec promtail cat /tmp/positions.yaml
```

### Kiểm tra file paths

Đảm bảo các file path trong `promtail-config.yml` khớp với thực tế:

```bash
# List files trong log directories
ls -la app-logs/
ls -la nginx-logs/
ls -la audit-logs/*/
```

### Container không start

```bash
# Check container logs
docker compose logs

# Check Docker resources
docker system df

# Restart Docker daemon nếu cần
sudo systemctl restart docker  # Linux
# hoặc restart Docker Desktop trên macOS
```

## 📝 Ghi Log Từ Application

### NestJS Example

```typescript
import { Injectable, Logger } from '@nestjs/common';

@Injectable()
export class AppService {
  private readonly logger = new Logger(AppService.name);

  getHello(): string {
    this.logger.log('Processing request');
    this.logger.error('Database error', 'trace');
    return 'Hello World!';
  }
}
```

Logs sẽ được ghi vào `app-logs/app.log`

## 📚 Documentation

Chi tiết cài đặt xem file `setup-documentation.tex` hoặc build PDF:

```bash
# Cài đặt LaTeX
# Ubuntu/Debian
sudo apt-get install texlive-latex-base texlive-latex-extra texlive-lang-other

# macOS
brew install --cask mactex

# Build PDF
pdflatex setup-documentation.tex
```

## 🎯 Next Steps

1. Cấu hình Grafana dashboards
2. Setup alerts
3. Configure log rotation
4. Integrate với application thật
5. Setup MongoDB/Postgres audit logging

