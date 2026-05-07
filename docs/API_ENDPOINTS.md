# Employee Attendance Tracking System - REST API Endpoints

## Authentication
All API endpoints require JWT Bearer token authentication except login endpoints.
Header: `Authorization: Bearer <jwt_token>`

## Base URL
`https://api.attendancetracker.com/v1`

## Response Format
```json
{
  "success": true,
  "data": {},
  "message": "Optional message",
  "timestamp": "2024-01-01T00:00:00Z"
}
```

---

## 🔐 AUTHENTICATION ENDPOINTS

### Super Admin Login
**POST** `/auth/super-admin/login`
```json
// Request
{
  "email": "admin@attendancetracker.com",
  "password": "password123"
}

// Response
{
  "success": true,
  "data": {
    "token": "jwt_token_here",
    "user": {
      "id": "uuid",
      "email": "admin@attendancetracker.com",
      "role": "super_admin"
    }
  }
}
```

### Employee Mobile Login - Send OTP
**POST** `/auth/employee/send-otp`
```json
// Request
{
  "phone": "+91-9876543210",
  "countryCode": "IN"
}

// Response
{
  "success": true,
  "message": "OTP sent successfully"
}
```

### Employee Mobile Login - Verify OTP
**POST** `/auth/employee/verify-otp`
```json
// Request
{
  "phone": "+91-9876543210",
  "otp": "123456"
}

// Response
{
  "success": true,
  "data": {
    "token": "jwt_token_here",
    "user": {
      "id": "uuid",
      "name": "John Doe",
      "companyId": "uuid",
      "role": "employee"
    },
    "isNewUser": false
  }
}
```

---

## 👑 SUPER ADMIN ENDPOINTS

### Dashboard Statistics
**GET** `/super-admin/dashboard/stats`
```json
// Response
{
  "success": true,
  "data": {
    "totalCompanies": 48,
    "activeCompanies": 42,
    "totalUsers": 1240,
    "todayAlerts": 7,
    "companiesGrowth": 3,
    "activePercentage": 87.5
  }
}
```

### Companies List
**GET** `/super-admin/companies`
Query params: `page=1&limit=20&search=abc&plan=pro&status=active`
```json
// Response
{
  "success": true,
  "data": {
    "companies": [
      {
        "id": "uuid",
        "name": "ABC Corporation",
        "ownerName": "Rahul Sharma",
        "email": "rahul@abc.com",
        "plan": "Professional",
        "users": 45,
        "maxUsers": 100,
        "locations": 12,
        "status": "active",
        "joinedAt": "2024-01-12T00:00:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 48,
      "totalPages": 3
    }
  }
}
```

### Create Company
**POST** `/super-admin/companies`
```json
// Request
{
  "name": "XYZ Corp",
  "ownerName": "Jane Smith",
  "email": "jane@xyz.com",
  "phone": "+91-9876543210",
  "city": "Mumbai",
  "state": "Maharashtra",
  "planId": "uuid",
  "maxUsers": 100
}

// Response
{
  "success": true,
  "data": {
    "company": { /* company object */ },
    "loginCredentials": {
      "email": "jane@xyz.com",
      "tempPassword": "TempPass123!"
    }
  }
}
```

### Update Company
**PUT** `/super-admin/companies/{companyId}`
```json
// Request
{
  "name": "XYZ Corporation",
  "status": "suspended",
  "maxUsers": 150
}
```

### Company Details
**GET** `/super-admin/companies/{companyId}`
```json
// Response
{
  "success": true,
  "data": {
    "company": { /* full company object */ },
    "stats": {
      "totalEmployees": 85,
      "activeEmployees": 82,
      "totalLocations": 12,
      "todayCheckIns": 75
    },
    "recentActivity": [ /* activity logs */ ]
  }
}
```

### Plans Management
**GET** `/super-admin/plans`
**POST** `/super-admin/plans`
**PUT** `/super-admin/plans/{planId}`
**DELETE** `/super-admin/plans/{planId}`

### Billing Overview
**GET** `/super-admin/billing/overview`
```json
// Response
{
  "success": true,
  "data": {
    "monthlyRevenue": 125000.00,
    "pendingPayments": 5,
    "overduePayments": 2,
    "planDistribution": {
      "starter": 15,
      "professional": 25,
      "enterprise": 8
    }
  }
}
```

### Platform Alerts
**GET** `/super-admin/alerts`
Query params: `page=1&limit=20&type=mock_gps&severity=high`
```json
// Response
{
  "success": true,
  "data": {
    "alerts": [
      {
        "id": "uuid",
        "type": "mock_gps",
        "severity": "high",
        "message": "Mock GPS detected for employee John Doe",
        "companyName": "ABC Corp",
        "employeeName": "John Doe",
        "timestamp": "2024-01-15T10:32:00Z",
        "isResolved": false
      }
    ],
    "pagination": { /* pagination object */ }
  }
}
```

---

## 🏢 COMPANY ADMIN ENDPOINTS

### Dashboard Statistics
**GET** `/company/dashboard/stats`
```json
// Response
{
  "success": true,
  "data": {
    "totalEmployees": 85,
    "checkedInToday": 72,
    "outOfZoneNow": 3,
    "pendingApprovals": 5,
    "onlinePCs": 61
  }
}
```

### Employees Management
**GET** `/company/employees`
Query params: `page=1&limit=20&search=john&department=sales&status=active`

**POST** `/company/employees`
```json
// Request
{
  "name": "John Doe",
  "email": "john@company.com",
  "phone": "+91-9876543210",
  "department": "Sales",
  "designation": "Senior Sales Executive",
  "managerId": "uuid",
  "workStartTime": "09:00",
  "workEndTime": "18:00",
  "assignedZones": ["uuid1", "uuid2"]
}

// Response triggers OTP send to phone
```

**PUT** `/company/employees/{employeeId}`
**DELETE** `/company/employees/{employeeId}`

### Employee Details
**GET** `/company/employees/{employeeId}`
```json
// Response
{
  "success": true,
  "data": {
    "employee": { /* full employee object */ },
    "attendance": {
      "today": { /* today's attendance */ },
      "thisWeek": { /* weekly stats */ },
      "thisMonth": { /* monthly stats */ }
    },
    "pcActivity": { /* PC tracking data */ },
    "alerts": [ /* employee alerts */ ]
  }
}
```

### Locations Management
**GET** `/company/locations`
**POST** `/company/locations`
```json
// Request
{
  "name": "Pune Head Office",
  "type": "office",
  "address": "Baner Road, Pune, Maharashtra",
  "latitude": 18.5606,
  "longitude": 73.7871,
  "radiusMeters": 100,
  "assignedEmployees": ["uuid1", "uuid2"]
}
```
**PUT** `/company/locations/{locationId}`
**DELETE** `/company/locations/{locationId}`

### Live Map Data
**GET** `/company/live-map`
```json
// Response
{
  "success": true,
  "data": {
    "employees": [
      {
        "id": "uuid",
        "name": "John Doe",
        "latitude": 18.5606,
        "longitude": 73.7871,
        "zoneId": "uuid",
        "isInZone": true,
        "lastUpdate": "2024-01-15T10:30:00Z",
        "todayHours": 4.5
      }
    ],
    "zones": [
      {
        "id": "uuid",
        "name": "Pune Office",
        "latitude": 18.5606,
        "longitude": 73.7871,
        "radius": 100,
        "color": "#2563EB"
      }
    ]
  }
}
```

### Approvals Management
**GET** `/company/approvals`
Query params: `status=pending`

**POST** `/company/approvals/{requestId}/review`
```json
// Request
{
  "action": "approve", // or "reject"
  "radius": 150, // optional, for location approvals
  "notes": "Approved with adjusted radius"
}
```

### PC Agents Management
**GET** `/company/pc-agents`

**POST** `/company/pc-agents/generate-token`
```json
// Request
{
  "employeeId": "uuid"
}

// Response
{
  "success": true,
  "data": {
    "token": "TKN-8F3K-2025-XYZQ",
    "installerUrl": "https://...",
    "tokenFileUrl": "https://..."
  }
}
```

### Reports
**GET** `/company/reports/attendance`
Query params: `startDate=2024-01-01&endDate=2024-01-31&employeeId=uuid&department=sales`

**GET** `/company/reports/productivity`
**GET** `/company/reports/zones`
**GET** `/company/reports/alerts`

### Export Reports
**POST** `/company/reports/export`
```json
// Request
{
  "type": "attendance", // attendance, productivity, zones, alerts
  "format": "pdf", // pdf, excel
  "filters": {
    "startDate": "2024-01-01",
    "endDate": "2024-01-31",
    "employeeIds": ["uuid1", "uuid2"]
  }
}

// Response
{
  "success": true,
  "data": {
    "downloadUrl": "https://...",
    "expiresAt": "2024-01-15T11:00:00Z"
  }
}
```

### Alerts Management
**GET** `/company/alerts`
**PUT** `/company/alerts/{alertId}/mark-read`

### Settings
**GET** `/company/settings`
**PUT** `/company/settings`
```json
// Request
{
  "idleThresholdMinutes": 5,
  "productiveApps": ["chrome.exe", "excel.exe"],
  "workWeekends": false,
  "notificationSettings": {
    "emailAlerts": true,
    "pushNotifications": true
  }
}
```

---

## 📱 MOBILE APP ENDPOINTS

### Home Screen Data
**GET** `/mobile/home`
```json
// Response
{
  "success": true,
  "data": {
    "greeting": "Good Morning, John! 👋",
    "currentZone": {
      "name": "Pune Head Office",
      "isInZone": true,
      "distance": 23
    },
    "todayAttendance": {
      "punchIn": "09:02",
      "punchOut": null,
      "hoursToday": 4.5,
      "canPunch": true
    },
    "weeklyStats": {
      "daysPresent": 4,
      "totalDays": 5,
      "avgHours": 7.8
    },
    "pendingAlerts": 2
  }
}
```

### Punch Attendance
**POST** `/mobile/attendance/punch`
```json
// Request
{
  "type": "in", // "in" or "out"
  "latitude": 18.5606,
  "longitude": 73.7871,
  "accuracy": 5.2,
  "isMock": false
}

// Response
{
  "success": true,
  "data": {
    "punchTime": "2024-01-15T09:02:00Z",
    "zoneName": "Pune Head Office",
    "message": "Punched in successfully"
  }
}
```

### Submit Location Request
**POST** `/mobile/location-request`
```json
// Request
{
  "locationName": "Client Meeting - XYZ Corp",
  "type": "client",
  "reason": "Client presentation meeting",
  "latitude": 18.5204,
  "longitude": 73.8567
}
```

### Attendance History
**GET** `/mobile/attendance/history`
Query params: `month=2024-01`

### Map Data
**GET** `/mobile/map`
```json
// Response
{
  "success": true,
  "data": {
    "currentLocation": {
      "latitude": 18.5606,
      "longitude": 73.7871
    },
    "zones": [
      {
        "id": "uuid",
        "name": "Pune Office",
        "latitude": 18.5606,
        "longitude": 73.7871,
        "radius": 100
      }
    ]
  }
}
```

### Profile
**GET** `/mobile/profile`
**PUT** `/mobile/profile`

### Raise Dispute
**POST** `/mobile/attendance/dispute`
```json
// Request
{
  "attendanceLogId": "uuid",
  "reason": "Was at client meeting, GPS not accurate"
}
```

---

## 💻 PC AGENT ENDPOINTS

### Agent Registration
**POST** `/agent/register`
```json
// Request
{
  "token": "TKN-8F3K-2025-XYZQ",
  "hardwareId": "A1B2C3D4E5F6",
  "pcName": "JOHN-PC",
  "osVersion": "Windows 10 Pro"
}

// Response
{
  "success": true,
  "data": {
    "agentId": "uuid",
    "syncInterval": 60,
    "config": { /* agent config */ }
  }
}
```

### Sync Activity Data
**POST** `/agent/sync`
```json
// Request
{
  "agentId": "uuid",
  "sessionStart": "2024-01-15T09:00:00Z",
  "sessionEnd": "2024-01-15T18:00:00Z",
  "activeMinutes": 480,
  "idleMinutes": 20,
  "appUsage": [
    {
      "appName": "chrome.exe",
      "windowTitle": "Google Chrome",
      "durationMinutes": 120,
      "isProductive": true
    }
  ],
  "isOfflineSync": false
}
```

### Heartbeat
**POST** `/agent/heartbeat`
```json
// Request
{
  "agentId": "uuid",
  "timestamp": "2024-01-15T10:30:00Z"
}
```

### Get Configuration
**GET** `/agent/config/{agentId}`
```json
// Response
{
  "success": true,
  "data": {
    "idleThreshold": 5,
    "productiveApps": ["chrome.exe", "outlook.exe"],
    "syncInterval": 60,
    "workHours": {
      "start": "09:00",
      "end": "18:00"
    }
  }
}
```

---

## 🔄 WEBSOCKET ENDPOINTS

### Real-time Updates
WebSocket URL: `wss://api.attendancetracker.com/v1/ws`

#### Subscribe to Live Map
```json
{
  "action": "subscribe",
  "channel": "live-map",
  "companyId": "uuid"
}
```

#### Live Map Updates
```json
{
  "type": "employee_location",
  "data": {
    "employeeId": "uuid",
    "latitude": 18.5606,
    "longitude": 73.7871,
    "zoneId": "uuid",
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

#### Alert Notifications
```json
{
  "type": "alert",
  "data": {
    "id": "uuid",
    "type": "mock_gps",
    "message": "Mock GPS detected",
    "employeeName": "John Doe",
    "timestamp": "2024-01-15T10:32:00Z"
  }
}
```

---

## 📊 ANALYTICS ENDPOINTS

### Company Analytics
**GET** `/analytics/company/{companyId}/overview`
**GET** `/analytics/company/{companyId}/attendance-trends`
**GET** `/analytics/company/{companyId}/productivity-metrics`
**GET** `/analytics/company/{companyId}/zone-compliance`

### Platform Analytics (Super Admin)
**GET** `/analytics/platform/overview`
**GET** `/analytics/platform/growth-metrics`
**GET** `/analytics/platform/usage-statistics`

---

## 🔧 SYSTEM ENDPOINTS

### Health Check
**GET** `/health`
```json
{
  "status": "healthy",
  "timestamp": "2024-01-15T10:30:00Z",
  "services": {
    "database": "up",
    "redis": "up",
    "firebase": "up"
  }
}
```

### Version Info
**GET** `/version`
```json
{
  "version": "1.0.0",
  "build": "2024-01-15",
  "environment": "production"
}
```

---

## 📋 RATE LIMITS

- Mobile login OTP: 5 requests per hour per phone
- API calls: 1000 requests per hour per user
- File uploads: 10 MB per file, 100 MB per hour
- WebSocket connections: 1 per user

---

## 🚨 ERROR RESPONSES

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": {
      "field": "email",
      "reason": "Invalid email format"
    }
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

### Common Error Codes
- `VALIDATION_ERROR`: Invalid input data
- `UNAUTHORIZED`: Invalid or missing authentication
- `FORBIDDEN`: Insufficient permissions
- `NOT_FOUND`: Resource not found
- `RATE_LIMITED`: Too many requests
- `MOCK_GPS_DETECTED`: Fake GPS location detected
- `OUT_OF_ZONE`: Employee outside allowed zones