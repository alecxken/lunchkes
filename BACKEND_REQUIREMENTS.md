# Backend API Requirements for Data Sync & CSV Export

This document outlines the backend endpoints that need to be implemented or updated to support the improved data synchronization and CSV export features.

## New/Updated Endpoints

### 1. Export Data to CSV
**Endpoint:** `GET /api/lunch/export`

**Query Parameters:**
- `start_date` (optional): Start date filter (YYYY-MM-DD)
- `end_date` (optional): End date filter (YYYY-MM-DD)
- `category` (optional): Filter by category (staff|contract|visitor|consultant)

**Response:**
```json
{
  "status": "success",
  "message": "Data exported successfully",
  "data": {
    "csv": "name,category,date,time,verified_by,comments\nJohn Doe,staff,2024-01-15,12:30:00,Admin,\n..."
  }
}
```

**CSV Format:**
```csv
name,category,date,time,verified_by,comments,synced
John Doe,staff,2024-01-15,12:30:00,Admin,,true
Jane Smith,visitor,2024-01-15,12:35:00,Admin,Visiting: HR | Company: Acme Inc,true
```

---

### 2. Clear Synced Data
**Endpoint:** `POST /api/lunch/clear-synced`

**Purpose:** Delete old synced records to manage storage

**Request Body:**
```json
{
  "older_than_days": 90
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Cleared 150 old records",
  "data": {
    "deleted_count": 150
  }
}
```

---

### 3. Enhanced Sync Endpoint (Already exists, needs updates)
**Endpoint:** `POST /api/lunch/sync`

**Current Behavior:** Syncs pending records to permanent storage

**Required Updates:**
- After successful sync, check total storage size
- If storage > 100MB, automatically delete synced records older than 90 days
- Return storage info in response

**Enhanced Response:**
```json
{
  "status": "success",
  "message": "Synced 25 records",
  "data": {
    "synced_count": 25,
    "pending_count": 0,
    "storage_size_mb": 45.2,
    "cleanup_performed": false
  }
}
```

---

## Storage Management Logic (Backend)

### Auto-Cleanup Rules
1. **After each sync operation:**
   - Check total database/storage size
   - If size > 100MB, delete synced records older than 90 days (3 months)
   - Keep all pending (unsynced) records regardless of age

2. **Data Retention:**
   - Pending records: Keep indefinitely until synced
   - Synced records: Keep for 90 days or until storage exceeds 100MB
   - Priority: Recent data and pending records

3. **Cleanup Query Example (Laravel/SQL):**
```sql
DELETE FROM lunch_records
WHERE synced = true
  AND created_at < DATE_SUB(NOW(), INTERVAL 90 DAY)
  AND (SELECT SUM(data_length + index_length) / 1024 / 1024
       FROM information_schema.tables
       WHERE table_schema = DATABASE()) > 100;
```

---

## Implementation Notes

### Frontend Changes (Already Implemented)
✅ CSV export button (admin only - checks username contains "admin")
✅ Improved sync with retry logic (3 attempts with exponential backoff)
✅ Auto-clear local cache after successful sync
✅ Local storage cleanup (removes data older than 90 days)
✅ Storage size monitoring

### Backend TODO
- [ ] Implement `/api/lunch/export` endpoint
- [ ] Implement `/api/lunch/clear-synced` endpoint
- [ ] Update `/api/lunch/sync` endpoint to include auto-cleanup logic
- [ ] Add storage size monitoring to database
- [ ] Add scheduled job/cron to run daily cleanup

### Admin Authentication
Currently, admin detection is based on username containing "admin". For production:
- Consider implementing proper role-based access control (RBAC)
- Add `is_admin` field to users table
- Protect export endpoint with admin middleware

### CSV Export Performance
For large datasets:
- Consider implementing pagination or streaming for exports
- Add date range limits (e.g., max 1 year at a time)
- Consider background job processing for very large exports

---

## Testing Checklist

- [ ] Test CSV export with various date ranges
- [ ] Test CSV export with category filters
- [ ] Test sync with retry on network failure
- [ ] Verify local cache is cleared after successful sync
- [ ] Verify old data cleanup when storage exceeds 100MB
- [ ] Test admin-only access to export button
- [ ] Verify CSV file downloads correctly in browser
- [ ] Test data retention (90-day policy)

---

## Configuration

### Environment Variables (Backend)
```env
STORAGE_LIMIT_MB=100
DATA_RETENTION_DAYS=90
SYNC_MAX_RETRIES=3
```

### Frontend Configuration
Location: `lib/services/storage_service.dart`
```dart
static const int maxStorageMB = 100;
static const int dataRetentionDays = 90; // 3 months
```

---

## Migration Guide

1. Deploy frontend changes (this update)
2. Update backend API to include new endpoints
3. Test in staging environment
4. Deploy to production
5. Monitor storage usage and cleanup performance
6. Adjust retention policy if needed based on usage patterns
