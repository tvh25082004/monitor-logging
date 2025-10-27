# ✅ Kiểm Tra Hệ Thống Grafana

## 🎯 Tóm Tắt Setup

Hệ thống PLG Stack đã được setup và đang chạy!

### Containers Status
```bash
✅ loki - Running (Port 3100)
✅ promtail - Running
✅ grafana - Running (Port 3000)
```

### Logs Available
```bash
✅ application logs
✅ nginx logs  
✅ mongodb audit logs
✅ postgres audit logs
✅ application audit logs
```

## 🚀 Truy Cập Grafana

1. **URL**: http://localhost:3000
2. **Username**: admin
3. **Password**: admin

## 📋 Checklist Kiểm Tra

### ✅ Bước 1: Đăng Nhập Grafana

1. Mở http://localhost:3000
2. Nhập username: `admin`, password: `admin`
3. Click "Log in"

### ✅ Bước 2: Kiểm Tra Data Source

1. Vào **Configuration** (⚙️ icon) > **Data Sources**
2. Chọn **Loki**
3. Click **"Explore"** hoặc **"Test"**
4. Phải thấy: "Data source is working" màu xanh

**Nếu chưa có data source:**
- Click **"Add data source"**
- Chọn **Loki**
- URL: `http://loki:3100`
- Click **"Save & Test"**

### ✅ Bước 3: Query Logs Trong Explore

1. Click icon **"Explore"** (Compass icon) ở sidebar
2. Chọn data source: **Loki**
3. Nhập query:
```logql
{job="application"}
```
4. Click **"Run query"**
5. Phải thấy kết quả với log message

### ✅ Bước 4: Kiểm Tra Các Loại Logs

#### Application Logs
```logql
{job="application"}
```

#### Nginx Logs
```logql
{job="nginx"}
```

#### MongoDB Audit Logs
```logql
{job="mongodb"}
```

#### Postgres Audit Logs
```logql
{job="postgres"}
```

Tất cả đều phải return kết quả!

## ⚙️ Config Cần Thiết (Đã Xong ✅)

### ✅ Đã Cấu Hình

1. **Docker Compose** ✅
   - Loki, Promtail, Grafana containers
   - Network setup
   - Volume mounts

2. **Promtail Config** ✅
   - Đã cấu hình thu thập logs từ:
     - app-logs/
     - nginx-logs/
     - audit-logs/*/

3. **Loki Config** ✅
   - Retention: 7 days
   - Port: 3100

4. **Grafana** ✅
   - Data source auto-configured
   - Dashboard folders ready

5. **Log Directories** ✅
   - Tất cả directories đã được tạo

## 🔍 Kiểm Tra Logs Trong Promtail

```bash
# Xem Promtail đang watch file nào
docker exec promtail cat /tmp/positions.yaml

# Xem Promtail logs
docker logs promtail

# Xem Promtail targets
docker exec promtail cat /etc/promtail/config.yml
```

## 🔍 Query Logs Trong Grafana

Chi tiết query: Xem file `GRAFANA-QUERY-GUIDE.md`

### Query Nhanh

```logql
# All logs
{job="application"}

# Only errors
{job="application"} |= "error"

# Nginx access logs
{job="nginx"}

# MongoDB audit
{job="mongodb"}

# Last 15 minutes
{job="application"}[15m]
```

## 📊 Tạo Dashboard

### Bước 1: Tạo Dashboard Mới

1. Vào **Dashboards** > **New Dashboard**
2. Click **"Add visualization"**

### Bước 2: Chọn Data Source

1. Chọn **"Loki"**
2. Query: `{job="application"}`
3. Visualization: Chọn **"Logs"**

### Bước 3: Save Dashboard

1. Click **"Save"**
2. Đặt tên dashboard
3. Click **"Save dashboard"**

## 🎨 Dashboard Panels Mẫu

### Panel 1: Error Logs

```logql
{job="application"} |= "error"
```
Type: **Logs**

### Panel 2: Request Count

```logql
count_over_time({job="nginx"}[5m])
```
Type: **Time series**

### Panel 3: All Application Logs

```logql
{job="application"}
```
Type: **Logs**

## 🔧 Troubleshooting

### Không thấy logs trong Grafana

#### 1. Check Promtail
```bash
docker logs promtail --tail 50
```

Phải thấy:
```
msg="tail routine: started" path=/app-logs/app.log
```

#### 2. Check Loki
```bash
curl http://localhost:3100/ready
```

Phải return: `ready`

#### 3. Check Logs Exist
```bash
ls -la app-logs/
cat app-logs/app.log
```

#### 4. Restart Promtail
```bash
docker restart promtail
```

#### 5. Check Query Time Range
- Ở góc trên phải Grafana Explore
- Chọn **"Last 15 minutes"** hoặc **"Last 1 hour"**

### Data Source Không Hoạt Động

1. Vào **Configuration** > **Data Sources** > **Loki**
2. Click **"Test"**
3. Nếu lỗi, xem: **docker logs grafana**

### Container Không Chạy

```bash
# Check status
docker compose ps

# Start containers
docker compose up -d

# Check logs
docker compose logs -f
```

## ✅ Kết Quả Mong Đợi

Khi vào Grafana Explore và query `{job="application"}`:

Bạn sẽ thấy:
```
2025-10-27 15:00:14 [INFO] New test log after Promtail started
2025-10-27 07:57:45 [ERROR] Database connection timeout
2025-10-27 07:57:45 [WARN] Memory usage high: 85%
```

Labels:
```
job="application"
service="backend"
filename="/app-logs/app.log"
```

## 📝 Next Steps

### 1. Tích Hợp Với Application Thật

- Sử dụng config trong `config/logger.config.ts`
- Application sẽ ghi logs vào `app-logs/`

### 2. Setup Nginx Logs Thật

- Copy config từ `config/nginx.conf.example`
- Nginx sẽ ghi vào `nginx-logs/`

### 3. Enable Database Audit Logs

**MongoDB:**
```bash
# Mount config
docker run -v $(pwd)/config/mongodb-audit.conf:/etc/mongod.conf \
  mongo --config /etc/mongod.conf
```

**Postgres:**
- Chạy SQL trong `config/postgres-audit.sql`

### 4. Tạo Alerts

- Vào **Alerting** trong Grafana
- Tạo alert rules cho errors, slow queries, etc.

### 5. Setup Dashboards

- Tạo dashboard cho từng loại log
- Setup time range filters
- Add to favorites

## 🎉 Kết Luận

Hệ thống đã setup thành công! 

**Truy cập**: http://localhost:3000
**Query logs**: `{job="application"}`
**Xem hướng dẫn**: `GRAFANA-QUERY-GUIDE.md`

Tất cả config đã đầy đủ và sẵn sàng sử dụng!

