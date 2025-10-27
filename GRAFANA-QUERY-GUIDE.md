# Hướng Dẫn Query Logs Trong Grafana

## 🚀 Truy Cập Grafana

**URL**: http://localhost:3000
**Username**: admin
**Password**: admin

## 📊 Các Bước Để Xem Logs

### Bước 1: Vào Explore Section

1. Click vào biểu tượng **Compass** (Explore) ở menu bên trái
2. Hoặc click vào **"Explore"** ở sidebar

### Bước 2: Chọn Data Source

- Chọn **"Loki"** từ dropdown "Select data source"

### Bước 3: Query Logs

Dán các query sau vào ô **"Enter a LogQL query"**:

## 🔍 Các Query Cơ Bản

### 1. Xem Tất Cả Application Logs

```logql
{job="application"}
```

### 2. Xem Logs Kèm Filter

```logql
{job="application"} |= "error"
```

Xem chỉ errors:
```logql
{job="application"} |= "ERROR"
```

Xem chỉ info logs:
```logql
{job="application"} |= "INFO"
```

### 3. Xem Nginx Access Logs

```logql
{job="nginx"}
```

Xem GET requests:
```logql
{job="nginx"} |~ "GET"
```

Xem POST requests:
```logql
{job="nginx"} |~ "POST"
```

Xem status 200:
```logql
{job="nginx"} |= "200"
```

### 4. Xem MongoDB Audit Logs

```logql
{job="mongodb"}
```

Xem slow queries:
```logql
{job="mongodb", log_type="slowquery"}
```

### 5. Xem Postgres Audit Logs

```logql
{job="postgres"}
```

### 6. Xem Application Audit Logs

```logql
{job="application", log_type="audit"}
```

## 📈 Query Nâng Cao

### Filter với Regex

```logql
{job="nginx"} |~ "GET.*/api/.*200"
```

### Count Logs

```logql
count_over_time({job="application"}[5m])
```

### Rate của Requests

```logql
rate({job="nginx"}[5m])
```

### Aggregate theo File

```logql
topk(10, count_over_time({job="application"}[1h]))
```

### Error Rate

```logql
sum(rate({job="application"} |= "error" [5m]))
```

## 🎯 Các Query Mẫu Hay Dùng

### 1. Tìm Tất Cả Errors Trong 1 Giờ Qua

```logql
{job="application"} |= "error" [1h]
```

### 2. Xem Logs Gần Đây Nhất

```logql
{job="application"}
```

Sau đó chọn time range: **Last 5 minutes** ở góc trên phải

### 3. Filter Theo Time Range

- Ở góc trên phải Grafana
- Chọn: **Last 15 minutes**, **Last 1 hour**, etc.
- Hoặc chọn custom range

### 4. Search Trong Log Content

```logql
{job="application"} |~ "database"
```

Tìm log chứa từ "database"

### 5. Combine Multiple Jobs

```logql
{job=~"application|nginx"}
```

Xem logs từ cả application và nginx

## 📋 Time Range

Ở góc trên phải màn hình Grafana, bạn có thể chọn:

- **Last 5 minutes**
- **Last 15 minutes**
- **Last 1 hour**
- **Last 3 hours**
- **Last 6 hours**
- **Last 12 hours**
- **Last 24 hours**
- **Custom range** - Chọn thời gian cụ thể

## 🎨 Visualization Options

Sau khi query, ở tab **"Options"** phía dưới:

1. **Logs visualization**: Hiển thị dạng danh sách logs
2. **Table visualization**: Hiển thị dạng bảng
3. **Time series**: Hiển thị dạng biểu đồ theo thời gian

## 💡 Tips

1. **Lưu Query**: Click nút "Save" để lưu query yêu thích
2. **Add to Dashboard**: Click "Add to dashboard" để tạo dashboard
3. **Query History**: Click vào icon clock để xem query history
4. **Copy Results**: Click vào log line để copy nội dung

## 🔥 Query Cho Monitoring Thường Ngày

### Check System Health

```logql
{job="application"} |= "health" OR {job="application"} |= "started"
```

### Monitor Errors

```logql
{job="application"} |= "error" OR {job="application"} |= "ERROR"
```

### Track API Calls

```logql
{job="nginx"} |~ "/api/"
```

### Slow Queries

```logql
{job="mongodb", log_type="slowquery"} OR {job="postgres"}
```

### Track User Actions

```logql
{job="application", log_type="audit"} |~ "login"
```

## 📊 Ví Dụ Dashboard Queries

Tạo dashboard với các panel sau:

### Panel 1: Error Logs
```logql
{job="application"} |= "error"
```

### Panel 2: Request Count
```logql
count_over_time({job="nginx"}[5m])
```

### Panel 3: Application Status
```logql
{job="application"} |= "INFO"
```

### Panel 4: Audit Logs
```logql
{job="application", log_type="audit"}
```

## 🚨 Alerting Query

Để setup alerts:

1. Vào **"Alerting"** trong Grafana
2. Tạo alert rule với query:

```logql
count_over_time({job="application"} |= "error" [5m]) > 10
```

Alert sẽ trigger khi có hơn 10 errors trong 5 phút

## ✅ Test Nhanh

1. Mở http://localhost:3000
2. Vào **Explore**
3. Query: `{job="application"}`
4. Chọn time range: **Last 5 minutes**
5. Bạn sẽ thấy log: "New test log after Promtail started"

